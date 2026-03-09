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
  default     = "terraform-rds"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "identifier" {
  description = "Optional explicit DB cluster identifier."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where RDS will run."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Existing DB subnet group name to reuse."
  type        = string
  default     = null
}

variable "create_db_subnet_group" {
  description = "Create DB subnet group automatically from discovered subnets."
  type        = bool
  default     = true
}

variable "db_subnet_group_subnet_ids" {
  description = "Optional explicit subnet IDs for DB subnet group."
  type        = list(string)
  default     = []
}

variable "subnet_tier_tag_key" {
  description = "Subnet tier tag key used in discovery."
  type        = string
  default     = "Tier"
}

variable "database_subnet_tier_values" {
  description = "Preferred subnet tier values for database subnet discovery."
  type        = list(string)
  default     = ["database"]
}

variable "private_subnet_tier_values" {
  description = "Fallback subnet tier values for private subnet discovery."
  type        = list(string)
  default     = ["private"]
}

variable "create_security_group" {
  description = "Create dedicated security group for RDS."
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Additional security groups attached to cluster."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "IPv4 CIDRs allowed to access DB port."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to access DB port."
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Cluster engine."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Optional engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS cluster instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "create_reader_instance" {
  description = "Create optional read-only instance in cluster."
  type        = bool
  default     = false
}

variable "reader_instance_identifier" {
  description = "Optional explicit reader identifier."
  type        = string
  default     = null
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master username."
  type        = string
  default     = "appadmin"
}

variable "manage_master_user_password" {
  description = "If true, RDS manages master password."
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password when manage_master_user_password is false."
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Expose DB cluster instances publicly."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption."
  type        = bool
  default     = true
}

variable "create_custom_kms_keys" {
  description = "Create custom KMS keys in this stack for RDS storage and Secrets Manager."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "Existing custom KMS key ARN/ID for RDS storage encryption."
  type        = string
  default     = null
}

variable "master_user_secret_kms_key_id" {
  description = "Existing custom KMS key ARN/ID for managed master secret encryption."
  type        = string
  default     = null
}

variable "performance_insights_kms_key_id" {
  description = "Existing custom KMS key ARN/ID for Performance Insights."
  type        = string
  default     = null
}

variable "kms_deletion_window_in_days" {
  description = "Deletion window in days for custom KMS keys."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic key rotation for custom KMS keys."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Preferred maintenance window."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Protect DB cluster from deletion."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrade for cluster instances."
  type        = bool
  default     = true
}

variable "create_parameter_group" {
  description = "Create custom parameter group."
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "Parameter group family when create_parameter_group is true."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Parameter group parameters."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of DB logs exported to CloudWatch."
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds (0 disables)."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "create_enhanced_monitoring_role" {
  description = "Create IAM role and policy attachment for Enhanced Monitoring."
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "Existing IAM Role ARN for Enhanced Monitoring."
  type        = string
  default     = null
}

variable "enhanced_monitoring_role_name" {
  description = "Optional explicit name for created Enhanced Monitoring role."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
