#Create a new vpc 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "vpc-project1-${var.student_name}"
    ManagedBy = "Terraform"
  }
}

# Create 4 subnets in 2 different AZs
locals {
  vpc_name = aws_vpc.main.tags["Name"]

  subnets = {
    a = {
      cidr   = var.subnet_a_cidr
      az     = var.az_1
      public = true
    }
    b = {
      cidr   = var.subnet_b_cidr
      az     = var.az_1
      public = false
    }
    c = {
      cidr   = var.subnet_c_cidr
      az     = var.az_2
      public = true
    }
    d = {
      cidr   = var.subnet_d_cidr
      az     = var.az_2
      public = false
    }
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = "${local.vpc_name}-subnet-${each.key}"
  }
}

# Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.vpc_name}-igw"
  }
}

# Create a route table for the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.allowed_cidr_ipv4_public
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.vpc_name}-public-rt"
  }
}

# Add the public route table to the 2 public subnets
resource "aws_route_table_association" "public" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if subnet.public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public.id
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${local.vpc_name}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]

  subnets = [
    for key, subnet in local.subnets :
    aws_subnet.subnets[key].id
    if subnet.public
  ]

  tags = {
    Name = "${local.vpc_name}-alb"
  }
}

# ALB security group
resource "aws_security_group" "alb" {
  name        = "${local.vpc_name}-alb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.alb_http_port
    to_port     = var.alb_http_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.allowed_cidr_ipv4_public]
  }

  ingress {
    from_port   = var.alb_https_port
    to_port     = var.alb_https_port
    protocol    = var.ingress_protocol
    cidr_blocks = [var.allowed_cidr_ipv4_public]
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_ip_protocol
    cidr_blocks = [var.allowed_cidr_ipv4_public]
  }
}

# Bastion security group
resource "aws_security_group" "bastion" {
  name   = "${local.vpc_name}-bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from administrator machine"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.ingress_protocol

    cidr_blocks = [
      var.allowed_cidr_ipv4_public
    ]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_ip_protocol

    cidr_blocks = [
      var.allowed_cidr_ipv4_public
    ]
  }

  tags = {
    Name = "${local.vpc_name}-bastion-sg"
  }
}

# Frontend security group
resource "aws_security_group" "frontend" {
  name   = "${local.vpc_name}-frontend-sg"
  vpc_id = aws_vpc.main.id

  # Flask vote application
  ingress {
    description     = "Allow ALB to reach Vote Flask app"
    from_port       = var.vote_outside_port
    to_port         = var.vote_outside_port
    protocol        = var.ingress_protocol
    security_groups = [aws_security_group.alb.id]
  }

  # Node.js result application
  ingress {
    description     = "Allow ALB to reach Result Node app"
    from_port       = var.result_outside_port
    to_port         = var.result_outside_port
    protocol        = var.ingress_protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from bastion"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.ingress_protocol
    security_groups = [
      aws_security_group.bastion.id
    ]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_ip_protocol
    cidr_blocks = [var.allowed_cidr_ipv4_public]
  }
}

# Redis-Worker security group
resource "aws_security_group" "middleware" {
  name        = "${local.vpc_name}-middleware-sg"
  description = "Security group for Worker + Redis instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Frontend to access Redis"
    from_port = var.redis_outside_port
    to_port   = var.redis_outside_port
    protocol  = var.ingress_protocol

    security_groups = [
      aws_security_group.frontend.id
    ]
  }

  ingress {
    description     = "SSH from bastion"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.ingress_protocol
    security_groups = [
      aws_security_group.bastion.id
    ]
  }

  tags = {
    Name = "${local.vpc_name}-middleware-sg"
  }
}

# PostgreSQL security group
resource "aws_security_group" "database" {
  name        = "${local.vpc_name}-database-sg"
  description = "Allow PostgreSQL from worker and result"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow worker to write votes"
    from_port       = var.psql_outside_port
    to_port         = var.psql_outside_port
    protocol        = var.ingress_protocol
    security_groups = [
      aws_security_group.middleware.id
    ]
  }

  ingress {
    description     = "SSH from bastion"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.ingress_protocol
    security_groups = [
      aws_security_group.bastion.id
    ]
  }

  ingress {
    description = "Result reads from PostgreSQL"
    from_port = var.psql_outside_port
    to_port   = var.psql_outside_port
    protocol  = var.ingress_protocol
    security_groups = [
      aws_security_group.frontend.id
    ]
  }

  ingress {
    description = "Replication"
    from_port = var.psql_outside_port
    to_port   = var.psql_outside_port
    protocol  = var.ingress_protocol
    self = true
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_ip_protocol
    cidr_blocks = [var.allowed_cidr_ipv4_public]
  }

  tags = {
    Name = "${local.vpc_name}-database-sg"
  }
}

# Create Vote target group
resource "aws_lb_target_group" "vote" {
  name     = "${local.vpc_name}-vote-tg"
  port     = var.vote_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30

    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${local.vpc_name}-vote-tg"
  }
}

# Create Result target group
resource "aws_lb_target_group" "result" {
  name     = "${local.vpc_name}-result-tg"
  port     = var.result_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30

    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${local.vpc_name}-result-tg"
  }
}

# Listener rule of the ALB on Vote app
resource "aws_lb_listener" "vote" {
  load_balancer_arn = aws_lb.alb.arn

  port     = var.vote_outside_port
  protocol = var.app_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vote.arn
  }
}

# Listener rule of the ALB on Result app
resource "aws_lb_listener" "result" {
  load_balancer_arn = aws_lb.alb.arn

  port     = var.result_outside_port
  protocol = var.app_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.result.arn
  }
}

# aws_image
data "aws_ami" "al2023" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = var.ami_filter_name_key
    values = [var.ami_name_pattern]
  }

  filter {
    name   = var.ami_filter_arch_key
    values = [var.ami_architecture]
  }
}

# Bastion hosts for Ansible SSH access (one per AZ)
resource "aws_instance" "bastion" {
  for_each = {
    a = "a"
    c = "c"
  }
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnets[each.value].id

  key_name = aws_key_pair.my_key.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  tags = {
    Name = "${local.vpc_name}-bastion-${each.key}"
    Role = "Bastion"
  }
}

# Create Frontend ec2 instance 
resource "aws_instance" "frontend" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if subnet.public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  associate_public_ip_address = true
  tags = {
    Name = "${local.vpc_name}-frontend-${each.key}"
  }
}

# Register all frontend instances with the Vote target group
resource "aws_lb_target_group_attachment" "vote" {
  for_each = aws_instance.frontend

  target_group_arn = aws_lb_target_group.vote.arn
  target_id        = each.value.id
  port             = var.vote_outside_port
}

# Register all frontend instances with the Result target group
resource "aws_lb_target_group_attachment" "result" {
  for_each = aws_instance.frontend

  target_group_arn = aws_lb_target_group.result.arn
  target_id        = each.value.id
  port             = var.result_outside_port
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  for_each = {
    a = {}
    c = {}
  }
  domain = "vpc"
  tags = {
    Name = "${local.vpc_name}-nat-eip-${each.key}"
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each = {
    a = "a"
    c = "c"
  }
  allocation_id = aws_eip.nat[each.key].id
  subnet_id = aws_subnet.subnets[each.value].id
  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "${local.vpc_name}-nat-${each.key}"
  }
}

# Create one private route table per AZ
resource "aws_route_table" "private" {
  for_each = {
    b = "a"
    d = "c"
  }
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.allowed_cidr_ipv4_public
    nat_gateway_id = aws_nat_gateway.nat[each.value].id
  }
  tags = {
    Name = "${local.vpc_name}-private-${each.key}"
  }
}

# Associate each private subnet with its own route table
resource "aws_route_table_association" "private" {
  for_each = {
    b = "b"
    d = "d"
  }
  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Create one instance in both AZs for Middleware
resource "aws_instance" "middleware" {
  for_each = {
    for key, subnet in local.subnets : key => subnet
    if !subnet.public
  }

  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnets[each.key].id
  key_name      = aws_key_pair.my_key.key_name

  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.middleware.id
  ]

#  user_data = file("worker-userdata.sh")

  tags = {
    Name = "${local.vpc_name}-middleware-${each.key}"
    Role = "Worker + Redis"
  }
}

# PostgreSQL Primary
resource "aws_instance" "postgres_primary" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.subnets["b"].id

  key_name = aws_key_pair.my_key.key_name

  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

#  user_data = file("postgres-primary.sh")

  tags = {
    Name = "${local.vpc_name}-postgres-primary"
    Role = "Primary"
  }
}

# PostgreSQL Standby
resource "aws_instance" "postgres_replica" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.subnets["d"].id

  key_name = aws_key_pair.my_key.key_name

  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

#  user_data = file("postgres-standby.sh")

  tags = {
    Name = "${local.vpc_name}-postgres-standby"
    Role = "Replica"
  }
}

# Generates a secure private key
resource "tls_private_key" "key_pair" {
  algorithm = var.private_key_algorithm
}

# Registers the public key with AWS
resource "aws_key_pair" "my_key" {
  key_name   = "${var.student_name}-project1-ssh-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Saves the private key locally as a .pem file
resource "local_file" "private_key" {
  content         = tls_private_key.key_pair.private_key_openssh
  filename        = "${path.root}/ansible/${var.student_name}-project1-ssh-key.pem"
  file_permission = "0400" 
}

# Generate yml directly for Ansible to use
resource "local_file" "ansible_inventory" {
  filename = "${path.root}/ansible/inventory.ini"
ssh
  content = <<EOF
[bastion]
%{ for name, instance in aws_instance.bastion ~}
${name} ansible_host=${instance.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${path.root}/ansible/${var.student_name}-ssh-key.pem
%{ endfor ~}

[frontend]
%{ for name, instance in aws_instance.frontend ~}
${name} ansible_host=${instance.private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${path.root}/ansible/${var.student_name}-ssh-key.pem
%{ endfor ~}

[middleware]
%{ for name, instance in aws_instance.middleware ~}
${name} ansible_host=${instance.private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${path.root}/ansible/${var.student_name}-ssh-key.pem ansible_ssh_common_args='-o ProxyJump=ec2-user@${aws_instance.bastion["a"].public_ip}'
%{ endfor ~}

[database]
postgres-primary ansible_host=${aws_instance.postgres_primary.private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${path.root}/ansible/${var.student_name}-ssh-key.pem ansible_ssh_common_args='-o ProxyJump=ec2-user@${aws_instance.bastion["a"].public_ip}'
postgres-standby ansible_host=${aws_instance.postgres_replica.private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${path.root}/ansible/${var.student_name}-ssh-key.pem ansible_ssh_common_args='-o ProxyJump=ec2-user@${aws_instance.bastion["c"].public_ip}'
EOF
}


