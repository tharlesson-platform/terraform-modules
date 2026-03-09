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
  default     = "terraform-security-baseline"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "audit_bucket_name" {
  description = "Audit S3 bucket name for CloudTrail and AWS Config logs. Must be globally unique."
  type        = string
}

variable "kms_alias_name" {
  description = "Optional KMS alias name. Must start with alias/."
  type        = string
  default     = null
}

variable "cloudtrail_name" {
  description = "Optional CloudTrail trail name."
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
  description = "Enable CloudTrail log file validation."
  type        = bool
  default     = true
}

variable "cloudtrail_management_events_read_write_type" {
  description = "Read/write selector for CloudTrail management events."
  type        = string
  default     = "All"
}

variable "cloudtrail_s3_key_prefix" {
  description = "S3 key prefix for CloudTrail objects."
  type        = string
  default     = "cloudtrail"
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
}

variable "config_s3_key_prefix" {
  description = "S3 key prefix for AWS Config objects."
  type        = string
  default     = "config"
}

variable "force_destroy_bucket" {
  description = "Allow Terraform to destroy the audit bucket even when it has objects."
  type        = bool
  default     = false
}

variable "log_expiration_days" {
  description = "Retention in days for audit logs in S3."
  type        = number
  default     = 3650
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
