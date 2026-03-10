output "cluster_arn" {
  description = "Resolved ECS cluster ARN used by this module."
  value       = local.resolved_cluster_arn
}

output "cluster_name" {
  description = "Resolved ECS cluster name used by this module."
  value       = local.resolved_cluster_name
}

output "service_id" {
  description = "ECS service ID."
  value       = aws_ecs_service.this.id
}

output "service_arn" {
  description = "ECS service ARN."
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Current ECS task definition ARN."
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "ECS task definition family."
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "ECS task definition revision."
  value       = aws_ecs_task_definition.this.revision
}

output "execution_role_arn" {
  description = "Resolved IAM execution role ARN."
  value       = local.resolved_execution_role_arn
}

output "task_role_arn" {
  description = "Resolved IAM task role ARN."
  value       = local.resolved_task_role_arn
}

output "cloudwatch_log_group_name" {
  description = "Resolved CloudWatch log group name used by container logs."
  value       = local.resolved_log_group_name
}

output "resolved_service_security_group_ids" {
  description = "Resolved security group IDs attached to ECS service."
  value       = local.resolved_service_security_group_ids
}

output "created_service_security_group_id" {
  description = "Created ECS service security group ID, if create_service_security_group is true."
  value       = try(aws_security_group.service[0].id, null)
}

output "alb_load_balancer_arn" {
  description = "ALB ARN created by this module when create_alb is true."
  value       = try(module.alb[0].load_balancer_arn, null)
}

output "alb_load_balancer_dns_name" {
  description = "ALB DNS name created by this module when create_alb is true."
  value       = try(module.alb[0].load_balancer_dns_name, null)
}

output "alb_listener_arn" {
  description = "ALB listener ARN created by this module when create_alb is true."
  value       = try(module.alb[0].listener_arn, null)
}

output "alb_target_group_arn" {
  description = "Resolved ALB target group ARN used by ECS service."
  value       = local.resolved_target_group_arn
}

output "alb_acm_certificate_arn" {
  description = "ACM certificate ARN created through ALB module when enabled."
  value       = try(module.alb[0].acm_certificate_arn, null)
}

output "service_autoscaling_target_id" {
  description = "Application Auto Scaling target ID for ECS service, if enabled."
  value       = try(aws_appautoscaling_target.service[0].id, null)
}

output "service_autoscaling_policy_arns" {
  description = "Autoscaling policy ARNs for ECS service."
  value = {
    cpu    = try(aws_appautoscaling_policy.cpu[0].arn, null)
    memory = try(aws_appautoscaling_policy.memory[0].arn, null)
  }
}
