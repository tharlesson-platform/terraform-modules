variable "name" {
  description = "Base name used for VPC and related resources."
  type        = string
}

variable "cidr_block" {
  description = "Primary CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability Zones to distribute subnets across."
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0
    error_message = "At least one availability zone must be provided in azs."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. One subnet per AZ index."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnet_cidrs) <= length(var.azs)
    error_message = "public_subnet_cidrs cannot have more entries than azs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. One subnet per AZ index."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.private_subnet_cidrs) <= length(var.azs)
    error_message = "private_subnet_cidrs cannot have more entries than azs."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets. One subnet per AZ index."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.database_subnet_cidrs) <= length(var.azs)
    error_message = "database_subnet_cidrs cannot have more entries than azs."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Instance tenancy for the VPC (default or dedicated)."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "instance_tenancy must be either default or dedicated."
  }
}

variable "map_public_ip_on_launch" {
  description = "Assign public IP automatically on public subnet instances."
  type        = bool
  default     = true
}

variable "enable_internet_gateway" {
  description = "Create and attach an Internet Gateway when public subnets exist."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway(s) for outbound internet from private/database subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Create a single shared NAT Gateway for all private subnets."
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per public subnet/AZ."
  type        = bool
  default     = false
}

variable "database_subnet_route_to_nat_gateway" {
  description = "If true, database subnets will get a 0.0.0.0/0 route to NAT."
  type        = bool
  default     = false
}

variable "create_database_subnet_group" {
  description = "Create aws_db_subnet_group when database subnets are defined."
  type        = bool
  default     = true
}

variable "database_subnet_group_name" {
  description = "Optional explicit name for DB subnet group."
  type        = string
  default     = null
}

variable "enable_s3_gateway_endpoint" {
  description = "Create a Gateway VPC Endpoint for S3."
  type        = bool
  default     = false
}

variable "enable_dynamodb_gateway_endpoint" {
  description = "Create a Gateway VPC Endpoint for DynamoDB."
  type        = bool
  default     = false
}

variable "attach_gateway_endpoints_to_public" {
  description = "Attach Gateway Endpoint routes to public route table."
  type        = bool
  default     = false
}

variable "attach_gateway_endpoints_to_private" {
  description = "Attach Gateway Endpoint routes to private route tables."
  type        = bool
  default     = true
}

variable "attach_gateway_endpoints_to_database" {
  description = "Attach Gateway Endpoint routes to database route tables."
  type        = bool
  default     = true
}

variable "manage_default_security_group" {
  description = "Manage default security group and clear inbound rules."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Traffic capture type for VPC flow logs: ACCEPT, REJECT, or ALL."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], upper(var.flow_logs_traffic_type))
    error_message = "flow_logs_traffic_type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_retention_in_days" {
  description = "CloudWatch log retention in days for flow logs."
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
      400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.flow_logs_retention_in_days)
    error_message = "flow_logs_retention_in_days must be a valid CloudWatch retention value."
  }
}

variable "flow_logs_log_group_name" {
  description = "Optional custom CloudWatch Log Group name for VPC flow logs."
  type        = string
  default     = null
}

variable "flow_logs_iam_role_name" {
  description = "Optional custom IAM role name for flow logs delivery."
  type        = string
  default     = null
}

variable "flow_logs_kms_key_id" {
  description = "Optional KMS key ID/ARN for CloudWatch log group encryption."
  type        = string
  default     = null
}

variable "flow_logs_max_aggregation_interval" {
  description = "Flow logs max aggregation interval in seconds (60 or 600)."
  type        = number
  default     = 60

  validation {
    condition     = contains([60, 600], var.flow_logs_max_aggregation_interval)
    error_message = "flow_logs_max_aggregation_interval must be 60 or 600."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags only for public subnets."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags only for private subnets."
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags only for database subnets."
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for NAT Gateways and EIPs."
  type        = map(string)
  default     = {}
}

variable "flow_logs_tags" {
  description = "Additional tags for flow logs resources."
  type        = map(string)
  default     = {}
}