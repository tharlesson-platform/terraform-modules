variable "bucket_name" {
  description = "S3 bucket name. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must follow S3 naming rules (lowercase letters, numbers, dots, and hyphens)."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership setting applied to the bucket."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
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
  description = "Restrict public bucket policies to only AWS service principals and authorized users."
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "Bucket versioning status."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Suspended"], var.versioning_status)
    error_message = "versioning_status must be Enabled or Suspended."
  }
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN used for encryption when sse_algorithm is aws:kms."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Keys for SSE-KMS to reduce KMS request costs."
  type        = bool
  default     = true
}

variable "lifecycle_current_version_expiration_days" {
  description = "Optional expiration in days for current object versions."
  type        = number
  default     = null

  validation {
    condition     = var.lifecycle_current_version_expiration_days == null || var.lifecycle_current_version_expiration_days > 0
    error_message = "lifecycle_current_version_expiration_days must be greater than zero when set."
  }
}

variable "lifecycle_noncurrent_version_expiration_days" {
  description = "Optional expiration in days for non-current object versions."
  type        = number
  default     = null

  validation {
    condition     = var.lifecycle_noncurrent_version_expiration_days == null || var.lifecycle_noncurrent_version_expiration_days > 0
    error_message = "lifecycle_noncurrent_version_expiration_days must be greater than zero when set."
  }
}

variable "bucket_policy_json" {
  description = "Optional bucket policy JSON."
  type        = string
  default     = null

  validation {
    condition     = var.bucket_policy_json == null || can(jsondecode(var.bucket_policy_json))
    error_message = "bucket_policy_json must be valid JSON when provided."
  }
}

variable "access_log_bucket_name" {
  description = "Optional target bucket name for server access logs."
  type        = string
  default     = null

  validation {
    condition     = var.access_log_bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.access_log_bucket_name))
    error_message = "access_log_bucket_name must follow S3 naming rules when provided."
  }
}

variable "access_log_prefix" {
  description = "Optional prefix used for server access logs objects."
  type        = string
  default     = null

  validation {
    condition     = var.access_log_prefix == null || !startswith(var.access_log_prefix, "/")
    error_message = "access_log_prefix must not start with '/'."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
