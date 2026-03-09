variable "name" {
  description = "Base name used for RDS resources."
  type        = string
}

variable "identifier" {
  description = "Optional explicit cluster identifier. Defaults to name."
  type        = string
  default     = null
}

variable "engine" {
  description = "Cluster engine. Accepts aurora-postgresql/aurora-mysql (or postgres/mysql and will be mapped)."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Optional engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Cluster instance class for writer/reader."
  type        = string
}

variable "create_reader_instance" {
  description = "Create an additional read-only instance in the cluster."
  type        = bool
  default     = false
}

variable "writer_instance_identifier" {
  description = "Optional explicit writer instance identifier."
  type        = string
  default     = null
}

variable "reader_instance_identifier" {
  description = "Optional explicit reader instance identifier."
  type        = string
  default     = null
}

variable "reader_promotion_tier" {
  description = "Promotion tier for reader instance (0-15). Lower is promoted first."
  type        = number
  default     = 15

  validation {
    condition     = var.reader_promotion_tier >= 0 && var.reader_promotion_tier <= 15
    error_message = "reader_promotion_tier must be between 0 and 15."
  }
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = null
}

variable "username" {
  description = "Master username."
  type        = string
  default     = "appadmin"
}

variable "manage_master_user_password" {
  description = "If true, RDS manages the master password in Secrets Manager."
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password when manage_master_user_password is false."
  type        = string
  default     = null
  sensitive   = true
}

variable "master_user_secret_kms_key_id" {
  description = "Optional KMS key ARN/ID to encrypt the managed master user secret."
  type        = string
  default     = null
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Expose cluster instances publicly."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where the security group and subnet discovery will run."
  type        = string
}

variable "create_db_subnet_group" {
  description = "Create DB subnet group in this module when no existing group is provided."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Existing DB subnet group name to reuse."
  type        = string
  default     = null
}

variable "db_subnet_group_subnet_ids" {
  description = "Explicit subnet IDs for DB subnet group. If empty, module discovers subnets by tags."
  type        = list(string)
  default     = []
}

variable "subnet_tier_tag_key" {
  description = "Tag key used to detect subnet tiers."
  type        = string
  default     = "Tier"
}

variable "database_subnet_tier_values" {
  description = "Preferred tag values for database subnet discovery."
  type        = list(string)
  default     = ["database"]
}

variable "private_subnet_tier_values" {
  description = "Fallback tag values for private subnet discovery."
  type        = list(string)
  default     = ["private"]
}

variable "create_security_group" {
  description = "Create dedicated security group for RDS."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Optional explicit security group name."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description used in created security group."
  type        = string
  default     = "Managed by Terraform for RDS access."
}

variable "security_group_ids" {
  description = "Additional or existing security group IDs attached to cluster."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "IPv4 CIDRs allowed to connect to DB port in created SG."
  type        = list(string)
  default     = []
}

variable "allowed_ipv6_cidr_blocks" {
  description = "IPv6 CIDRs allowed to connect to DB port in created SG."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to DB port in created SG."
  type        = list(string)
  default     = []
}

variable "allow_all_outbound" {
  description = "Allow all outbound traffic from created SG."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 1 and 35."
  }
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
  description = "Protect cluster from accidental deletion."
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

variable "copy_tags_to_snapshot" {
  description = "Copy cluster tags to snapshots."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply modifications immediately."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades for cluster instances."
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication on the cluster."
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Database logs exported to CloudWatch."
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 disables)."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "Optional KMS key ARN/ID for Performance Insights."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days."
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "performance_insights_retention_period must be 7 or 731."
  }
}

variable "storage_encrypted" {
  description = "Enable cluster storage encryption."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS key ARN/ID for cluster storage encryption."
  type        = string
  default     = null
}

variable "ca_cert_identifier" {
  description = "Optional CA certificate identifier for cluster instances."
  type        = string
  default     = null
}

variable "create_parameter_group" {
  description = "Create DB parameter group in this module."
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Existing or custom parameter group name."
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family (for example aurora-postgresql16)."
  type        = string
  default     = null
}

variable "parameters" {
  description = "List of DB parameters for created parameter group."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for parameter in var.parameters : (
        parameter.apply_method == null || contains(["immediate", "pending-reboot"], lower(parameter.apply_method))
      )
    ])
    error_message = "parameters.apply_method must be immediate or pending-reboot when provided."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags only for cluster and cluster instances."
  type        = map(string)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags for security group."
  type        = map(string)
  default     = {}
}

variable "parameter_group_tags" {
  description = "Additional tags for parameter group."
  type        = map(string)
  default     = {}
}
