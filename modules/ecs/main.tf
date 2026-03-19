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
