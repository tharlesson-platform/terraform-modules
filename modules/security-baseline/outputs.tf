output "kms_key_id" {
  description = "KMS key ID used by the security baseline."
  value       = aws_kms_key.this.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used by the security baseline."
  value       = aws_kms_key.this.arn
}

output "kms_alias_name" {
  description = "KMS alias name used by the security baseline."
  value       = aws_kms_alias.this.name
}

output "audit_bucket_name" {
  description = "Audit S3 bucket name used by CloudTrail and AWS Config."
  value       = aws_s3_bucket.audit.id
}

output "audit_bucket_arn" {
  description = "Audit S3 bucket ARN used by CloudTrail and AWS Config."
  value       = aws_s3_bucket.audit.arn
}

output "cloudtrail_name" {
  description = "CloudTrail trail name."
  value       = aws_cloudtrail.this.name
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN."
  value       = aws_cloudtrail.this.arn
}

output "config_role_name" {
  description = "IAM role name used by AWS Config."
  value       = aws_iam_role.config.name
}

output "config_role_arn" {
  description = "IAM role ARN used by AWS Config."
  value       = aws_iam_role.config.arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name."
  value       = aws_config_configuration_recorder.this.name
}

output "config_delivery_channel_name" {
  description = "AWS Config delivery channel name."
  value       = aws_config_delivery_channel.this.name
}
