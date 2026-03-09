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
  default     = "terraform-s3"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name. Must be globally unique."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete bucket objects during destroy."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "block_public_acls" {
  description = "Block new public ACLs and uploading public objects."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block bucket policies that allow public access."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore all public ACLs on this bucket and objects."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies to authorized users and AWS services."
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "Versioning status (Enabled or Suspended)."
  type        = string
  default     = "Enabled"
}

variable "sse_algorithm" {
  description = "Bucket encryption algorithm (AES256 or aws:kms)."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN used when sse_algorithm is aws:kms."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 bucket key when using SSE-KMS."
  type        = bool
  default     = true
}

variable "lifecycle_current_version_expiration_days" {
  description = "Optional expiration in days for current object versions."
  type        = number
  default     = null
}

variable "lifecycle_noncurrent_version_expiration_days" {
  description = "Optional expiration in days for non-current object versions."
  type        = number
  default     = null
}

variable "access_log_bucket_name" {
  description = "Optional target bucket for S3 server access logs."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Optional prefix for S3 server access logs."
  type        = string
  default     = null
}

variable "bucket_policy_json" {
  description = "Optional bucket policy JSON."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
