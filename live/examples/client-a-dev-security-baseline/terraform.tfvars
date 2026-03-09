region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-security-baseline-client-a-dev"

client      = "client-a"
environment = "dev"

# Bucket precisa ser globalmente unico em todas as contas AWS.
audit_bucket_name = "client-a-dev-security-baseline-logs-123456789012-us-east-1"

kms_alias_name  = null
cloudtrail_name = null

enable_cloudtrail                            = true
is_multi_region_trail                        = true
include_global_service_events                = true
enable_log_file_validation                   = true
cloudtrail_management_events_read_write_type = "All"
cloudtrail_s3_key_prefix                     = "cloudtrail"

config_include_global_resource_types = true
config_snapshot_delivery_frequency   = "TwentyFour_Hours"
config_s3_key_prefix                 = "config"

force_destroy_bucket = false
log_expiration_days  = 3650

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}
