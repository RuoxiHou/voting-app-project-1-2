locals {
  name_prefix = "${var.project_name}-${var.student_name}"

  public_subnets = {
    public-a = {
      cidr = var.public_subnet_a
      az   = var.az_1
    }

    public-b = {
      cidr = var.public_subnet_b
      az   = var.az_2
    }
  }

  private_eks_subnets = {
    private-a = {
      cidr = var.private_subnet_a
      az   = var.az_1
    }

    private-b = {
      cidr = var.private_subnet_b
      az   = var.az_2
    }
  }

  private_rds_subnets = {
    private-c = {
      cidr = var.private_subnet_c
      az   = var.az_1
    }

    private-d = {
      cidr = var.private_subnet_d
      az   = var.az_2
    }
  }

  private_route_mapping = {
    private-a = "public-a"
    private-b = "public-b"
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# Public Subnets
# Used by internet-facing AWS Load Balancer Controller ALBs
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${local.name_prefix}-${each.key}"
    Purpose                                         = "alb"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" # Terraform owns this subnet. EKS may use it. 
    "kubernetes.io/role/elb"                        = "1"      # This is a PUBLIC subnet and internet-facing load balancers may be created here.
  }
}

# Private EKS Subnets
# Used by EKS managed node groups
resource "aws_subnet" "private_eks" {
  for_each = local.private_eks_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name                                            = "${local.name_prefix}-${each.key}"
    Purpose                                         = "eks"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1" # This is a PRIVATE subnet and internal load balancers may be created here.
  }
}

# Private RDS Subnets
# Used only by RDS PostgreSQL subnet group
#
resource "aws_subnet" "private_rds" {
  for_each = local.private_rds_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name    = "${local.name_prefix}-${each.key}"
    Purpose = "rds"
  }
}

# Combined private subnet reference
locals {
  all_private_subnet_ids = merge(
    {
      for key, subnet in aws_subnet.private_eks :
      key => subnet.id
    },
    {
      for key, subnet in aws_subnet.private_rds :
      key => subnet.id
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip-${each.key}"
  }
}

# NAT Gateways
# One NAT Gateway per public subnet / AZ
resource "aws_nat_gateway" "vpc" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  depends_on = [
    aws_internet_gateway.vpc
  ]

  tags = {
    Name = "${local.name_prefix}-nat-${each.key}"
  }
}

# Private Route Tables
# private-a uses NAT in public-a, private-b uses NAT in public-b
resource "aws_route_table" "private" {
  for_each = local.private_eks_subnets

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.vpc[
      local.private_route_mapping[each.key]
    ].id
  }

  tags = {
    Name = "${local.name_prefix}-${each.key}-rt"
  }
}

# Associate Private EKS Subnets with Private Route Tables
resource "aws_route_table_association" "private_eks" {
  for_each = aws_subnet.private_eks

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# Private RDS Subnets do not need to talk to outside VPC
resource "aws_route_table" "private_rds" {
  for_each = local.private_rds_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name_prefix}-${each.key}-rt"
  }
}

# Associate Private RDS Subnets with their isolated (no-internet) Route Tables
resource "aws_route_table_association" "private_rds" {
  for_each = aws_subnet.private_rds

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rds[each.key].id
}