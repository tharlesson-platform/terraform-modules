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

  dynamic "volume" {
    for_each = var.task_definition_volumes
    content {
      name      = volume.value.name
      host_path = try(volume.value.host_path, null)

      dynamic "efs_volume_configuration" {
        for_each = try(volume.value.efs_volume_configuration, null) == null ? [] : [volume.value.efs_volume_configuration]
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, null)
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, null)
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)

          dynamic "authorization_config" {
            for_each = try(efs_volume_configuration.value.authorization_config, null) == null ? [] : [efs_volume_configuration.value.authorization_config]
            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, null)
            }
          }
        }
      }
    }
  }

  container_definitions = coalesce(var.container_definitions_json, jsonencode([local.container_definition]))

  tags = merge(local.common_tags, var.task_definition_tags, {
    Name = local.task_definition_family
  })
}
