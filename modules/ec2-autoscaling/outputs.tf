output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_min_size" {
  description = "Minimum number of instances configured in the Auto Scaling Group."
  value       = aws_autoscaling_group.this.min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum number of instances configured in the Auto Scaling Group."
  value       = aws_autoscaling_group.this.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity configured in the Auto Scaling Group."
  value       = aws_autoscaling_group.this.desired_capacity
}

output "autoscaling_group_target_group_arns" {
  description = "Target group ARNs attached to the Auto Scaling Group."
  value       = aws_autoscaling_group.this.target_group_arns
}

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "ARN of the launch template."
  value       = aws_launch_template.this.arn
}

output "launch_template_name" {
  description = "Name of the launch template."
  value       = aws_launch_template.this.name
}

output "launch_template_latest_version" {
  description = "Latest version number of the launch template."
  value       = aws_launch_template.this.latest_version
}

output "resolved_subnet_ids" {
  description = "Subnet IDs used by Auto Scaling Group (explicit or auto-discovered)."
  value       = local.resolved_subnet_ids
}

output "discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered when subnet_ids is empty."
  value       = local.discovered_private_subnet_ids
}

output "resolved_security_group_ids" {
  description = "Security groups attached to launch template instances."
  value       = local.resolved_security_group_ids
}

output "created_security_group_id" {
  description = "Created security group ID, if create_security_group is true."
  value       = try(aws_security_group.this[0].id, null)
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to launch template instances."
  value       = local.resolved_iam_instance_profile
}

output "created_iam_role_name" {
  description = "Created IAM role name, if create_instance_profile is true."
  value       = try(aws_iam_role.this[0].name, null)
}

output "cpu_target_tracking_policy_arn" {
  description = "ARN of built-in CPU target tracking policy, if enabled."
  value       = try(aws_autoscaling_policy.cpu_target_tracking[0].arn, null)
}

output "target_tracking_policy_arns" {
  description = "ARNs of additional target tracking policies keyed by policy name."
  value = {
    for name, policy in aws_autoscaling_policy.target_tracking :
    name => policy.arn
  }
}
