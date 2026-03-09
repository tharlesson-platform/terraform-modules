variable "region" {
  description = "AWS region."
  type        = string
}

variable "aws_profile" {
  description = "Optional AWS CLI profile."
  type        = string
  default     = null
}

variable "aws_assume_role_arn" {
  description = "Optional IAM Role ARN to assume in target AWS account."
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name used when assuming role."
  type        = string
  default     = "terraform-vpc"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "azs" {
  description = "Availability zones to use."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "Database subnet CIDRs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

