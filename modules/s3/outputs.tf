output "bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "S3 bucket hosted zone ID."
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "versioning_status" {
  description = "Applied bucket versioning status."
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}

output "sse_algorithm" {
  description = "Server-side encryption algorithm configured on the bucket."
  value = one(flatten([
    for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule : [
      for encryption in rule.apply_server_side_encryption_by_default : encryption.sse_algorithm
    ]
  ]))
}

output "kms_key_arn" {
  description = "KMS key ARN used by the bucket when SSE-KMS is enabled."
  value = try(one(flatten([
    for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule : [
      for encryption in rule.apply_server_side_encryption_by_default : encryption.kms_master_key_id
    ]
  ])), null)
}

output "lifecycle_enabled" {
  description = "Whether lifecycle configuration is enabled for the bucket."
  value       = local.lifecycle_enabled
}

output "access_logging_enabled" {
  description = "Whether server access logging is enabled."
  value       = var.access_log_bucket_name != null
}
