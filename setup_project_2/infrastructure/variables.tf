variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "student_name" {
  description = "Student name used in resource names"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "project2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a" {
  description = "Public subnet CIDR in AZ 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b" {
  description = "Public subnet CIDR in AZ 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_a" {
  description = "Private subnet CIDR in AZ 1"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_b" {
  description = "Private subnet CIDR in AZ 2"
  type        = string
  default     = "10.0.12.0/24"
}

variable "private_subnet_c" {
  description = "Private RDS subnet CIDR in AZ 1"
  type        = string
  default     = "10.0.13.0/24"
}

variable "private_subnet_d" {
  description = "Private RDS subnet CIDR in AZ 2"
  type        = string
  default     = "10.0.14.0/24"
}

variable "az_1" {
  description = "First availability zone"
  type        = string
  default     = "us-west-2a"
}

variable "az_2" {
  description = "Second availability zone"
  type        = string
  default     = "us-west-2b"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "voting-app-eks"
}

variable "eks_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}

variable "db_identifier" {
  description = "RDS PostgreSQL identifier"
  type        = string
  default     = "voting-app-postgres"
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "votes"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Public DNS domain name, for example example.com"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Existing Route53 Hosted Zone ID"
  type        = string
}
