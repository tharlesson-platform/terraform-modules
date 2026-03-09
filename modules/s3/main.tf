check "access_log_prefix_requires_access_log_bucket" {
  assert {
    condition     = var.access_log_bucket_name != null || var.access_log_prefix == null
    error_message = "access_log_prefix can only be set when access_log_bucket_name is provided."
  }
}

locals {
  lifecycle_enabled = var.lifecycle_current_version_expiration_days != null || var.lifecycle_noncurrent_version_expiration_days != null

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "s3"
  })
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? var.bucket_key_enabled : null

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_arn : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = local.lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "default-retention"
    status = "Enabled"

    filter {}

    dynamic "expiration" {
      for_each = var.lifecycle_current_version_expiration_days == null ? [] : [var.lifecycle_current_version_expiration_days]
      content {
        days = expiration.value
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.lifecycle_noncurrent_version_expiration_days == null ? [] : [var.lifecycle_noncurrent_version_expiration_days]
      content {
        noncurrent_days = noncurrent_version_expiration.value
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.access_log_bucket_name == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_log_bucket_name
  target_prefix = coalesce(var.access_log_prefix, "${var.bucket_name}/")
}

resource "aws_s3_bucket_policy" "this" {
  count = var.bucket_policy_json == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy_json
}
