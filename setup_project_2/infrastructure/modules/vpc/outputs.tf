output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_eks_subnet_ids" {
  value = [for subnet in aws_subnet.private_eks : subnet.id]
}

output "private_rds_subnet_ids" {
  value = [for subnet in aws_subnet.private_rds : subnet.id]
}