variable "name_prefix" {
  description = "Prefix used to compose resource names for the security baseline."
  type        = string
}

variable "audit_bucket_name" {
  description = "S3 bucket name used by CloudTrail and AWS Config for audit logs. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.audit_bucket_name))
    error_message = "audit_bucket_name must follow S3 naming rules (lowercase letters, numbers, dots, and hyphens)."
  }
}

variable "kms_alias_name" {
  description = "Optional KMS alias name. Must start with alias/."
  type        = string
  default     = null

  validation {
    condition     = var.kms_alias_name == null || startswith(var.kms_alias_name, "alias/")
    error_message = "kms_alias_name must start with alias/."
  }
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days (7-30)."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic annual KMS key rotation."
  type        = bool
  default     = true
}

variable "cloudtrail_name" {
  description = "Optional CloudTrail trail name. Defaults to <name_prefix>-cloudtrail."
  type        = string
  default     = null
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail logging."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Create a multi-region CloudTrail trail."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Include global service events in CloudTrail."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable CloudTrail log file integrity validation."
  type        = bool
  default     = true
}

variable "cloudtrail_management_events_read_write_type" {
  description = "Read/write selector for CloudTrail management events."
  type        = string
  default     = "All"

  validation {
    condition     = contains(["All", "ReadOnly", "WriteOnly"], var.cloudtrail_management_events_read_write_type)
    error_message = "cloudtrail_management_events_read_write_type must be All, ReadOnly, or WriteOnly."
  }
}

variable "cloudtrail_s3_key_prefix" {
  description = "Optional S3 key prefix for CloudTrail objects."
  type        = string
  default     = "cloudtrail"

  validation {
    condition     = !startswith(var.cloudtrail_s3_key_prefix, "/")
    error_message = "cloudtrail_s3_key_prefix must not start with '/'."
  }
}

variable "config_role_name" {
  description = "Optional IAM role name for AWS Config. Defaults to <name_prefix>-config-role."
  type        = string
  default     = null
}

variable "config_recorder_name" {
  description = "Optional AWS Config recorder name. Defaults to <name_prefix>-config-recorder."
  type        = string
  default     = null
}

variable "config_delivery_channel_name" {
  description = "Optional AWS Config delivery channel name. Defaults to <name_prefix>-config-delivery."
  type        = string
  default     = null
}

variable "config_include_global_resource_types" {
  description = "Include global IAM resources in AWS Config recording group."
  type        = bool
  default     = true
}

variable "config_snapshot_delivery_frequency" {
  description = "Snapshot delivery frequency for AWS Config."
  type        = string
  default     = "TwentyFour_Hours"

  validation {
    condition = contains([
      "One_Hour",
      "Three_Hours",
      "Six_Hours",
      "Twelve_Hours",
      "TwentyFour_Hours"
    ], var.config_snapshot_delivery_frequency)
    error_message = "config_snapshot_delivery_frequency must be One_Hour, Three_Hours, Six_Hours, Twelve_Hours, or TwentyFour_Hours."
  }
}

variable "config_s3_key_prefix" {
  description = "Optional S3 key prefix for AWS Config objects."
  type        = string
  default     = "config"

  validation {
    condition     = !startswith(var.config_s3_key_prefix, "/")
    error_message = "config_s3_key_prefix must not start with '/'."
  }
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to delete the audit bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "log_expiration_days" {
  description = "Retention in days applied to current and non-current versions in the audit bucket."
  type        = number
  default     = 3650

  validation {
    condition     = var.log_expiration_days > 0
    error_message = "log_expiration_days must be greater than zero."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
