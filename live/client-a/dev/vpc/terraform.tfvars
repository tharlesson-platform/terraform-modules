region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-vpc-client-a-dev"

client      = "client-a"
environment = "dev"

vpc_cidr = "10.50.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs   = ["10.50.0.0/21", "10.50.8.0/21", "10.50.16.0/21"]
private_subnet_cidrs  = ["10.50.32.0/21", "10.50.40.0/21", "10.50.48.0/21"]
database_subnet_cidrs = ["10.50.64.0/21", "10.50.72.0/21", "10.50.80.0/21"]

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}

