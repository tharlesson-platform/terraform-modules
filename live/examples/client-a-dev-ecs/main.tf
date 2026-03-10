locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "ecs"
  })
}

module "ecs" {
  source = "../../../modules/ecs"

  name                   = "${var.client}-${var.environment}-${var.workload_name}"
  cluster_name           = var.cluster_name
  create_cluster         = var.create_cluster
  existing_cluster_arn   = var.existing_cluster_arn
  service_name           = var.service_name
  task_definition_family = var.task_definition_family

  enable_container_insights = var.enable_container_insights

  container_image       = var.container_image
  container_name        = var.container_name
  container_port        = var.container_port
  container_protocol    = var.container_protocol
  container_command     = var.container_command
  container_entrypoint  = var.container_entrypoint
  container_environment = var.container_environment
  container_secrets     = var.container_secrets

  task_cpu         = var.task_cpu
  task_memory      = var.task_memory
  network_mode     = var.network_mode
  launch_type      = var.launch_type
  platform_version = var.platform_version

  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  log_group_name              = var.log_group_name
  log_group_retention_in_days = var.log_group_retention_in_days
  log_group_kms_key_id        = var.log_group_kms_key_id

  create_execution_role               = var.create_execution_role
  execution_role_arn                  = var.execution_role_arn
  execution_role_name                 = var.execution_role_name
  execution_role_policy_arns          = var.execution_role_policy_arns
  execution_role_permissions_boundary = var.execution_role_permissions_boundary

  create_task_role               = var.create_task_role
  task_role_arn                  = var.task_role_arn
  task_role_name                 = var.task_role_name
  task_role_policy_arns          = var.task_role_policy_arns
  task_role_permissions_boundary = var.task_role_permissions_boundary

  vpc_id                        = var.vpc_id
  service_subnet_ids            = var.service_subnet_ids
  assign_public_ip              = var.assign_public_ip
  create_service_security_group = var.create_service_security_group
  service_security_group_name   = var.service_security_group_name
  service_security_group_ids    = var.service_security_group_ids
  service_ingress_cidr_blocks   = var.service_ingress_cidr_blocks
  service_egress_cidr_blocks    = var.service_egress_cidr_blocks

  desired_count                      = var.desired_count
  scheduling_strategy                = var.scheduling_strategy
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  enable_execute_command             = var.enable_execute_command
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  propagate_tags                     = var.propagate_tags
  wait_for_steady_state              = var.wait_for_steady_state
  force_new_deployment               = var.force_new_deployment

  enable_load_balancer         = var.enable_load_balancer
  create_alb                   = var.create_alb
  alb_target_group_arn         = var.alb_target_group_arn
  alb_name                     = var.alb_name
  alb_internal                 = var.alb_internal
  alb_subnet_ids               = var.alb_subnet_ids
  create_alb_security_group    = var.create_alb_security_group
  alb_security_group_name      = var.alb_security_group_name
  alb_security_group_ids       = var.alb_security_group_ids
  alb_ingress_cidr_blocks      = var.alb_ingress_cidr_blocks
  alb_listener_port            = var.alb_listener_port
  alb_listener_protocol        = var.alb_listener_protocol
  alb_listener_ssl_policy      = var.alb_listener_ssl_policy
  alb_listener_certificate_arn = var.alb_listener_certificate_arn
  alb_target_group_name        = var.alb_target_group_name
  alb_target_group_port        = var.alb_target_group_port
  alb_target_group_protocol    = var.alb_target_group_protocol
  alb_health_check_path        = var.alb_health_check_path
  alb_health_check_matcher     = var.alb_health_check_matcher

  alb_create_acm_certificate        = var.alb_create_acm_certificate
  alb_acm_domain_name               = var.alb_acm_domain_name
  alb_acm_subject_alternative_names = var.alb_acm_subject_alternative_names
  alb_acm_validation_method         = var.alb_acm_validation_method
  alb_acm_hosted_zone_id            = var.alb_acm_hosted_zone_id
  alb_acm_create_route53_records    = var.alb_acm_create_route53_records
  alb_acm_wait_for_validation       = var.alb_acm_wait_for_validation

  enable_service_autoscaling      = var.enable_service_autoscaling
  autoscaling_min_capacity        = var.autoscaling_min_capacity
  autoscaling_max_capacity        = var.autoscaling_max_capacity
  autoscaling_cpu_target_value    = var.autoscaling_cpu_target_value
  autoscaling_memory_target_value = var.autoscaling_memory_target_value
  autoscaling_scale_in_cooldown   = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown  = var.autoscaling_scale_out_cooldown

  tags = local.common_tags
}

output "ecs_cluster_arn" {
  value = module.ecs.cluster_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_service_arn" {
  value = module.ecs.service_arn
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}

output "ecs_service_security_group_ids" {
  value = module.ecs.resolved_service_security_group_ids
}

output "alb_dns_name" {
  value = module.ecs.alb_load_balancer_dns_name
}

output "alb_target_group_arn" {
  value = module.ecs.alb_target_group_arn
}

output "alb_acm_certificate_arn" {
  value = module.ecs.alb_acm_certificate_arn
}
