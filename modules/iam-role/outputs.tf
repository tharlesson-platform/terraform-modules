output "role_name" {
  description = "IAM role name."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IAM role ARN."
  value       = aws_iam_role.this.arn
}

output "role_unique_id" {
  description = "IAM role unique ID."
  value       = aws_iam_role.this.unique_id
}
