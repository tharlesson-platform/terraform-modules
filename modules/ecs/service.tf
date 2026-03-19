resource "aws_security_group" "alb" {
  count = var.enable_load_balancer && var.create_alb && var.create_alb_security_group ? 1 : 0

  name        = local.alb_security_group_name
  description = "Managed by Terraform for ECS ALB access."
  vpc_id      = var.vpc_id
  ingress     = []
  egress      = []

  tags = merge(local.common_tags, var.alb_security_group_tags, {
    Name = local.alb_security_group_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_ipv4" {
  for_each = var.enable_load_balancer && var.create_alb && var.create_alb_security_group ? local.alb_ingress_cidrs_by_index : {}

  security_group_id = aws_security_group.alb[0].id
  ip_protocol       = "tcp"
  from_port         = var.alb_listener_port
  to_port           = var.alb_listener_port
  cidr_ipv4         = each.value
  description       = "Allow inbound traffic to ALB listener."
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_ipv4" {
  count = var.enable_load_balancer && var.create_alb && var.create_alb_security_group ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic from ALB."
}

resource "aws_security_group" "service" {
  count = var.create_service_security_group ? 1 : 0

  name        = local.service_security_group_name
  description = "Managed by Terraform for ECS service ENIs."
  vpc_id      = var.vpc_id
  ingress     = []
  egress      = []

  tags = merge(local.common_tags, var.service_security_group_tags, {
    Name = local.service_security_group_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "service_from_alb" {
  for_each = var.create_service_security_group && var.enable_load_balancer ? toset(local.resolved_alb_security_group_ids) : toset([])

  security_group_id            = aws_security_group.service[0].id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
  referenced_security_group_id = each.value
  description                  = "Allow ALB security groups to reach ECS container port."
}

resource "aws_vpc_security_group_ingress_rule" "service_from_cidrs" {
  for_each = var.create_service_security_group ? local.service_ingress_cidrs_by_index : {}

  security_group_id = aws_security_group.service[0].id
  ip_protocol       = "tcp"
  from_port         = var.container_port
  to_port           = var.container_port
  cidr_ipv4         = each.value
  description       = "Allow additional ingress to ECS container port."
}

resource "aws_vpc_security_group_egress_rule" "service_egress" {
  for_each = var.create_service_security_group ? local.service_egress_cidrs_by_index : {}

  security_group_id = aws_security_group.service[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = each.value
  description       = "Allow outbound traffic from ECS service."
}

module "alb" {
  count = var.enable_load_balancer && var.create_alb ? 1 : 0

  source = "../alb"

  name                             = coalesce(var.alb_name, "${var.name}-ecs")
  target_group_name                = var.alb_target_group_name
  internal                         = var.alb_internal
  subnet_ids                       = var.alb_subnet_ids
  security_group_ids               = local.resolved_alb_security_group_ids
  enable_deletion_protection       = var.alb_enable_deletion_protection
  idle_timeout                     = var.alb_idle_timeout
  create_target_group              = true
  vpc_id                           = var.vpc_id
  target_group_port                = local.resolved_target_group_port
  target_group_protocol            = var.alb_target_group_protocol
  target_type                      = "ip"
  protocol_version                 = var.alb_protocol_version
  deregistration_delay             = var.alb_deregistration_delay
  stickiness_enabled               = var.alb_stickiness_enabled
  stickiness_cookie_duration       = var.alb_stickiness_cookie_duration
  health_check_enabled             = true
  health_check_path                = var.alb_health_check_path
  health_check_matcher             = var.alb_health_check_matcher
  health_check_interval            = var.alb_health_check_interval
  health_check_timeout             = var.alb_health_check_timeout
  health_check_healthy_threshold   = var.alb_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.alb_health_check_unhealthy_threshold
  listener_port                    = var.alb_listener_port
  listener_protocol                = var.alb_listener_protocol
  listener_ssl_policy              = var.alb_listener_ssl_policy
  listener_certificate_arn         = var.alb_listener_certificate_arn
  listener_default_action_type     = "forward"

  create_acm_certificate        = var.alb_create_acm_certificate
  acm_domain_name               = var.alb_acm_domain_name
  acm_subject_alternative_names = var.alb_acm_subject_alternative_names
  acm_validation_method         = var.alb_acm_validation_method
  acm_hosted_zone_id            = var.alb_acm_hosted_zone_id
  acm_create_route53_records    = var.alb_acm_create_route53_records
  acm_validation_record_ttl     = var.alb_acm_validation_record_ttl
  acm_wait_for_validation       = var.alb_acm_wait_for_validation
  acm_certificate_tags          = var.alb_acm_certificate_tags

  tags               = local.common_tags
  load_balancer_tags = var.alb_tags
  target_group_tags  = var.alb_target_group_tags
}

resource "aws_ecs_service" "this" {
  name                               = local.service_name
  cluster                            = local.resolved_cluster_arn
  task_definition                    = aws_ecs_task_definition.this.arn
  launch_type                        = upper(var.launch_type)
  platform_version                   = local.is_fargate ? var.platform_version : null
  scheduling_strategy                = upper(var.scheduling_strategy)
  desired_count                      = upper(var.scheduling_strategy) == "DAEMON" ? null : var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = local.resolved_target_group_arn == null ? null : var.health_check_grace_period_seconds
  enable_execute_command             = var.enable_execute_command
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  propagate_tags                     = upper(var.propagate_tags)
  wait_for_steady_state              = var.wait_for_steady_state
  force_new_deployment               = var.force_new_deployment

  network_configuration {
    subnets          = var.service_subnet_ids
    security_groups  = local.resolved_service_security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = local.resolved_target_group_arn == null ? [] : [local.resolved_target_group_arn]
    content {
      target_group_arn = load_balancer.value
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  tags = merge(local.common_tags, var.service_tags, {
    Name = local.service_name
  })

  depends_on = [
    module.alb,
    aws_iam_role_policy_attachment.execution_default,
    aws_iam_role_policy_attachment.execution_additional,
    aws_vpc_security_group_ingress_rule.service_from_alb,
    aws_vpc_security_group_ingress_rule.service_from_cidrs,
    aws_vpc_security_group_egress_rule.service_egress
  ]
}

resource "aws_appautoscaling_target" "service" {
  count = var.enable_service_autoscaling ? 1 : 0

  min_capacity       = var.autoscaling_min_capacity
  max_capacity       = var.autoscaling_max_capacity
  resource_id        = "service/${local.resolved_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_service_autoscaling ? 1 : 0

  name               = "${local.service_name}-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling_cpu_target_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_service_autoscaling ? 1 : 0

  name               = "${local.service_name}-memory-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling_memory_target_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
