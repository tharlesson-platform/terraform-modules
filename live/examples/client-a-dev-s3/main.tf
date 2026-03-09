locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "s3"
  })
}

module "s3" {
  source = "../../../modules/s3"

  bucket_name       = var.bucket_name
  force_destroy     = var.force_destroy
  object_ownership  = var.object_ownership
  versioning_status = var.versioning_status

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  sse_algorithm      = var.sse_algorithm
  kms_key_arn        = var.kms_key_arn
  bucket_key_enabled = var.bucket_key_enabled

  lifecycle_current_version_expiration_days    = var.lifecycle_current_version_expiration_days
  lifecycle_noncurrent_version_expiration_days = var.lifecycle_noncurrent_version_expiration_days

  access_log_bucket_name = var.access_log_bucket_name
  access_log_prefix      = var.access_log_prefix

  bucket_policy_json = var.bucket_policy_json
  tags               = local.common_tags
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "bucket_regional_domain_name" {
  value = module.s3.bucket_regional_domain_name
}
