region      = "us-east-1"
aws_profile = "client-a-dev"

# Bootstrap opcional via role existente. Deixe null para usar credencial direta da conta alvo.
aws_assume_role_arn          = null
aws_assume_role_session_name = "terraform-s3-client-a-dev"

client      = "client-a"
environment = "dev"

# Bucket precisa ser globalmente unico em todas as contas AWS.
bucket_name = "client-a-dev-app-data-123456789012-us-east-1"

force_destroy     = false
object_ownership  = "BucketOwnerEnforced"
versioning_status = "Enabled"

block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

sse_algorithm      = "AES256"
kms_key_arn        = null
bucket_key_enabled = true

lifecycle_current_version_expiration_days    = null
lifecycle_noncurrent_version_expiration_days = null

access_log_bucket_name = null
access_log_prefix      = null

bucket_policy_json = null

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}
