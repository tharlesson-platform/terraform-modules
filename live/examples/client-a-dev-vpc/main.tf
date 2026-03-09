locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "vpc"
  })
}

module "vpc" {
  source = "../../../modules/vpc"

  name       = "${var.client}-${var.environment}-core-vpc"
  cidr_block = var.vpc_cidr
  azs        = var.azs

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_nat_gateway                   = true
  single_nat_gateway                   = false
  one_nat_gateway_per_az               = true
  database_subnet_route_to_nat_gateway = false

  create_database_subnet_group = true

  enable_s3_gateway_endpoint       = true
  enable_dynamodb_gateway_endpoint = true

  enable_flow_logs            = true
  flow_logs_retention_in_days = 30

  tags = local.common_tags
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

