data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

locals {
  normalized_requires_compatibilities = [
    for compatibility in var.requires_compatibilities :
    upper(compatibility)
  ]

  is_fargate = upper(var.launch_type) == "FARGATE" || contains(local.normalized_requires_compatibilities, "FARGATE")

  cluster_name                = coalesce(var.cluster_name, "${var.name}-cluster")
  service_name                = coalesce(var.service_name, "${var.name}-svc")
  task_definition_family      = coalesce(var.task_definition_family, "${var.name}-task")
  container_name              = coalesce(var.container_name, var.name)
  execution_role_name         = coalesce(var.execution_role_name, "${var.name}-ecs-exec-role")
  task_role_name              = coalesce(var.task_role_name, "${var.name}-ecs-task-role")
  service_security_group_name = coalesce(var.service_security_group_name, "${var.name}-ecs-svc-sg")
  alb_security_group_name     = coalesce(var.alb_security_group_name, "${var.name}-ecs-alb-sg")

  discovered_log_group_name = coalesce(var.log_group_name, "/ecs/${var.name}")

  resolved_cluster_arn = coalesce(
    try(aws_ecs_cluster.this[0].arn, null),
    var.existing_cluster_arn
  )

  resolved_cluster_name = coalesce(
    try(aws_ecs_cluster.this[0].name, null),
    try(split("/", var.existing_cluster_arn)[1], null)
  )

  resolved_execution_role_arn = coalesce(
    try(aws_iam_role.execution[0].arn, null),
    var.execution_role_arn
  )

  resolved_task_role_arn = coalesce(
    try(aws_iam_role.task[0].arn, null),
    var.task_role_arn
  )

  resolved_log_group_name = coalesce(
    try(aws_cloudwatch_log_group.this[0].name, null),
    var.log_group_name
  )

  resolved_alb_security_group_ids = var.enable_load_balancer && var.create_alb ? (
    var.create_alb_security_group ? [aws_security_group.alb[0].id] : var.alb_security_group_ids
  ) : []

  resolved_service_security_group_ids = compact(concat(
    var.create_service_security_group ? [aws_security_group.service[0].id] : [],
    var.service_security_group_ids
  ))

  resolved_target_group_arn = var.enable_load_balancer ? coalesce(
    try(module.alb[0].target_group_arn, null),
    var.alb_target_group_arn
  ) : null

  resolved_target_group_port = coalesce(var.alb_target_group_port, var.container_port)

  alb_ingress_cidrs_by_index = {
    for index, cidr in var.alb_ingress_cidr_blocks :
    tostring(index) => cidr
  }

  service_ingress_cidrs_by_index = {
    for index, cidr in var.service_ingress_cidr_blocks :
    tostring(index) => cidr
  }

  service_egress_cidrs_by_index = {
    for index, cidr in var.service_egress_cidr_blocks :
    tostring(index) => cidr
  }

  container_environment = [
    for key in sort(keys(var.container_environment)) :
    {
      name  = key
      value = var.container_environment[key]
    }
  ]

  container_secrets = [
    for secret in var.container_secrets :
    {
      name      = secret.name
      valueFrom = secret.value_from
    }
  ]

  container_definition = merge(
    {
      name                   = local.container_name
      image                  = var.container_image
      essential              = true
      readonlyRootFilesystem = var.container_readonly_root_filesystem
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = lower(var.container_protocol)
        }
      ]
      environment = local.container_environment
      secrets     = local.container_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.resolved_log_group_name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = var.container_log_stream_prefix
        }
      }
    },
    var.container_command == null ? {} : {
      command = var.container_command
    },
    var.container_entrypoint == null ? {} : {
      entryPoint = var.container_entrypoint
    },
    var.container_start_timeout == null ? {} : {
      startTimeout = var.container_start_timeout
    },
    var.container_stop_timeout == null ? {} : {
      stopTimeout = var.container_stop_timeout
    },
    var.container_health_check == null ? {} : {
      healthCheck = {
        command     = var.container_health_check.command
        interval    = try(var.container_health_check.interval, 30)
        timeout     = try(var.container_health_check.timeout, 5)
        retries     = try(var.container_health_check.retries, 3)
        startPeriod = try(var.container_health_check.start_period, 0)
      }
    }
  )

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "ecs"
    Workload  = var.name
  })
}

check "cluster_inputs_are_consistent" {
  assert {
    condition = var.create_cluster ? (
      var.existing_cluster_arn == null
      ) : (
      var.existing_cluster_arn != null
    )
    error_message = "When create_cluster is true, keep existing_cluster_arn null. When false, set existing_cluster_arn."
  }
}

check "execution_role_inputs_are_consistent" {
  assert {
    condition = var.create_execution_role ? (
      var.execution_role_arn == null
      ) : (
      var.execution_role_arn != null
    )
    error_message = "When create_execution_role is true, keep execution_role_arn null. When false, set execution_role_arn."
  }
}

check "task_role_inputs_are_consistent" {
  assert {
    condition = var.create_task_role ? (
      var.task_role_arn == null
      ) : (
      var.task_role_arn != null
    )
    error_message = "When create_task_role is true, keep task_role_arn null. When false, set task_role_arn."
  }
}

check "log_group_inputs_are_consistent" {
  assert {
    condition = var.create_cloudwatch_log_group ? (
      var.log_group_name == null || var.log_group_name == local.discovered_log_group_name
      ) : (
      var.log_group_name != null
    )
    error_message = "When create_cloudwatch_log_group is false, set log_group_name with an existing log group."
  }
}

check "service_security_group_inputs_are_consistent" {
  assert {
    condition = var.create_service_security_group ? (
      var.vpc_id != null
      ) : (
      length(var.service_security_group_ids) > 0
    )
    error_message = "When create_service_security_group is true, set vpc_id. When false, provide at least one service_security_group_ids value."
  }
}

check "service_security_group_resolution_is_valid" {
  assert {
    condition     = length(local.resolved_service_security_group_ids) > 0
    error_message = "ECS service requires at least one resolved security group."
  }
}

check "create_alb_security_group_requires_create_alb" {
  assert {
    condition     = var.create_alb || !var.create_alb_security_group
    error_message = "create_alb_security_group can only be true when create_alb is true."
  }
}

check "alb_inputs_are_consistent" {
  assert {
    condition = !var.enable_load_balancer || !var.create_alb || (
      var.vpc_id != null
      && length(var.alb_subnet_ids) >= 2
      && (var.create_alb_security_group || length(var.alb_security_group_ids) > 0)
    )
    error_message = "When create_alb is true, provide vpc_id, at least two alb_subnet_ids, and ALB security groups (created or existing)."
  }
}

check "existing_target_group_is_required_when_alb_is_not_created" {
  assert {
    condition     = !var.enable_load_balancer || var.create_alb || var.alb_target_group_arn != null
    error_message = "When enable_load_balancer is true and create_alb is false, set alb_target_group_arn."
  }
}

check "fargate_requires_awsvpc_network_mode" {
  assert {
    condition     = !local.is_fargate || var.network_mode == "awsvpc"
    error_message = "Fargate workloads require network_mode = awsvpc."
  }
}

check "fargate_requires_fargate_launch_type" {
  assert {
    condition     = !contains(local.normalized_requires_compatibilities, "FARGATE") || upper(var.launch_type) == "FARGATE"
    error_message = "When requires_compatibilities includes FARGATE, launch_type must be FARGATE."
  }
}

check "daemon_requires_ec2_launch_type" {
  assert {
    condition     = upper(var.scheduling_strategy) != "DAEMON" || upper(var.launch_type) == "EC2"
    error_message = "DAEMON scheduling_strategy requires launch_type = EC2."
  }
}

check "autoscaling_requires_replica_strategy" {
  assert {
    condition     = !var.enable_service_autoscaling || upper(var.scheduling_strategy) == "REPLICA"
    error_message = "enable_service_autoscaling requires scheduling_strategy = REPLICA."
  }
}

check "autoscaling_capacity_bounds_are_consistent" {
  assert {
    condition = !var.enable_service_autoscaling || (
      var.autoscaling_min_capacity <= var.autoscaling_max_capacity
      && var.desired_count >= var.autoscaling_min_capacity
      && var.desired_count <= var.autoscaling_max_capacity
    )
    error_message = "Autoscaling bounds must satisfy min <= desired_count <= max."
  }
}

check "alb_health_check_timeout_is_less_than_interval" {
  assert {
    condition     = var.alb_health_check_timeout < var.alb_health_check_interval
    error_message = "alb_health_check_timeout must be lower than alb_health_check_interval."
  }
}

resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, var.cluster_tags, {
    Name = local.cluster_name
  })
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = local.discovered_log_group_name
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(local.common_tags, var.log_group_tags, {
    Name = local.discovered_log_group_name
  })
}

resource "aws_iam_role" "execution" {
  count = var.create_execution_role ? 1 : 0

  name                 = local.execution_role_name
  description          = var.execution_role_description
  path                 = var.execution_role_path
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = var.execution_role_permissions_boundary

  tags = merge(local.common_tags, var.execution_role_tags, {
    Name = local.execution_role_name
  })
}

resource "aws_iam_role_policy_attachment" "execution_default" {
  count = var.create_execution_role ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution_additional" {
  for_each = var.create_execution_role ? toset(var.execution_role_policy_arns) : toset([])

  role       = aws_iam_role.execution[0].name
  policy_arn = each.value
}

resource "aws_iam_role" "task" {
  count = var.create_task_role ? 1 : 0

  name                 = local.task_role_name
  description          = var.task_role_description
  path                 = var.task_role_path
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = var.task_role_permissions_boundary

  tags = merge(local.common_tags, var.task_role_tags, {
    Name = local.task_role_name
  })
}

resource "aws_iam_role_policy_attachment" "task" {
  for_each = var.create_task_role ? toset(var.task_role_policy_arns) : toset([])

  role       = aws_iam_role.task[0].name
  policy_arn = each.value
}

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

resource "aws_ecs_task_definition" "this" {
  family                   = local.task_definition_family
  network_mode             = var.network_mode
  requires_compatibilities = local.normalized_requires_compatibilities
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = local.resolved_execution_role_arn
  task_role_arn            = local.resolved_task_role_arn

  runtime_platform {
    cpu_architecture        = upper(var.runtime_cpu_architecture)
    operating_system_family = upper(var.runtime_operating_system_family)
  }

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size == null ? [] : [var.ephemeral_storage_size]
    content {
      size_in_gib = ephemeral_storage.value
    }
  }

  container_definitions = jsonencode([local.container_definition])

  tags = merge(local.common_tags, var.task_definition_tags, {
    Name = local.task_definition_family
  })
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
