locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "security-baseline"
  })
}

module "security_baseline" {
  source = "../../../../modules/security-baseline"

  name_prefix = "${var.client}-${var.environment}"

  audit_bucket_name = var.audit_bucket_name
  kms_alias_name    = var.kms_alias_name

  cloudtrail_name                              = var.cloudtrail_name
  enable_cloudtrail                            = var.enable_cloudtrail
  is_multi_region_trail                        = var.is_multi_region_trail
  include_global_service_events                = var.include_global_service_events
  enable_log_file_validation                   = var.enable_log_file_validation
  cloudtrail_management_events_read_write_type = var.cloudtrail_management_events_read_write_type
  cloudtrail_s3_key_prefix                     = var.cloudtrail_s3_key_prefix

  config_include_global_resource_types = var.config_include_global_resource_types
  config_snapshot_delivery_frequency   = var.config_snapshot_delivery_frequency
  config_s3_key_prefix                 = var.config_s3_key_prefix

  force_destroy_bucket = var.force_destroy_bucket
  log_expiration_days  = var.log_expiration_days

  tags = local.common_tags
}

output "audit_bucket_name" {
  value = module.security_baseline.audit_bucket_name
}

output "cloudtrail_arn" {
  value = module.security_baseline.cloudtrail_arn
}

output "config_role_arn" {
  value = module.security_baseline.config_role_arn
}

output "config_recorder_name" {
  value = module.security_baseline.config_recorder_name
}

output "kms_key_arn" {
  value = module.security_baseline.kms_key_arn
}
