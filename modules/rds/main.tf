data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:${var.subnet_tier_tag_key}"
    values = var.database_subnet_tier_values
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:${var.subnet_tier_tag_key}"
    values = var.private_subnet_tier_values
  }
}

locals {
  identifier           = coalesce(var.identifier, var.name)
  cluster_engine       = lower(var.engine) == "postgres" ? "aurora-postgresql" : (lower(var.engine) == "mysql" ? "aurora-mysql" : var.engine)
  db_subnet_group_name = coalesce(var.db_subnet_group_name, "${local.identifier}-db-subnet-group")
  security_group_name  = coalesce(var.security_group_name, "${local.identifier}-rds-sg")
  parameter_group_name = coalesce(var.parameter_group_name, "${local.identifier}-${replace(local.cluster_engine, ".", "-")}-pg")

  should_create_db_subnet_group = var.db_subnet_group_name == null && var.create_db_subnet_group
  discovered_subnet_ids = length(var.db_subnet_group_subnet_ids) > 0 ? var.db_subnet_group_subnet_ids : (
    length(data.aws_subnets.database.ids) > 0 ? data.aws_subnets.database.ids : data.aws_subnets.private.ids
  )

  selected_subnet_source = !local.should_create_db_subnet_group ? "existing-subnet-group" : (
    length(var.db_subnet_group_subnet_ids) > 0 ? "provided" : (
      length(data.aws_subnets.database.ids) > 0 ? "database" : (
        length(data.aws_subnets.private.ids) > 0 ? "private" : "none"
      )
    )
  )

  resolved_db_subnet_group_name = local.should_create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  resolved_parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name

  resolved_vpc_security_group_ids = compact(concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.security_group_ids
  ))

  writer_instance_identifier = coalesce(var.writer_instance_identifier, "${local.identifier}-writer")
  reader_instance_identifier = coalesce(var.reader_instance_identifier, "${local.identifier}-reader")

  allowed_cidr_map      = { for index, cidr in var.allowed_cidr_blocks : tostring(index) => cidr }
  allowed_ipv6_cidr_map = { for index, cidr in var.allowed_ipv6_cidr_blocks : tostring(index) => cidr }
  allowed_sg_map        = { for sg_id in var.allowed_security_group_ids : sg_id => sg_id }

  common_tags = merge(var.tags, {
    ManagedBy    = "Terraform"
    Module       = "rds"
    DbIdentifier = local.identifier
  })
}

check "subnet_discovery_or_group_must_exist" {
  assert {
    condition     = (local.should_create_db_subnet_group && length(local.discovered_subnet_ids) > 0) || var.db_subnet_group_name != null
    error_message = "No subnets were found for DB subnet group creation. Provide db_subnet_group_name or ensure subnets exist with Tier=database or Tier=private tags."
  }
}

check "security_group_inputs_are_consistent" {
  assert {
    condition     = var.create_security_group || length(var.security_group_ids) > 0
    error_message = "When create_security_group is false, at least one existing security group id must be provided in security_group_ids."
  }
}

check "monitoring_role_is_required" {
  assert {
    condition     = var.monitoring_interval == 0 || var.monitoring_role_arn != null
    error_message = "monitoring_role_arn is required when monitoring_interval is greater than 0."
  }
}

check "master_password_mode_is_consistent" {
  assert {
    condition     = var.manage_master_user_password || var.master_password != null
    error_message = "master_password must be provided when manage_master_user_password is false."
  }
}

check "parameter_group_family_is_required" {
  assert {
    condition     = !var.create_parameter_group || var.parameter_group_family != null
    error_message = "parameter_group_family must be provided when create_parameter_group is true."
  }
}

check "final_snapshot_identifier_is_required" {
  assert {
    condition     = var.skip_final_snapshot || var.final_snapshot_identifier != null
    error_message = "final_snapshot_identifier must be provided when skip_final_snapshot is false."
  }
}

check "reader_identifier_must_be_different_from_writer" {
  assert {
    condition     = !var.create_reader_instance || local.reader_instance_identifier != local.writer_instance_identifier
    error_message = "reader_instance_identifier must be different from writer_instance_identifier."
  }
}

resource "aws_db_subnet_group" "this" {
  count = local.should_create_db_subnet_group ? 1 : 0

  name       = local.db_subnet_group_name
  subnet_ids = local.discovered_subnet_ids

  tags = merge(local.common_tags, {
    Name         = local.db_subnet_group_name
    SubnetSource = local.selected_subnet_source
  })
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name                   = local.security_group_name
  description            = var.security_group_description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(local.common_tags, var.security_group_tags, {
    Name = local.security_group_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group ? local.allowed_cidr_map : {}

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
  cidr_ipv4         = each.value
  description       = "Allow DB access from IPv4 CIDR ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "ipv6" {
  for_each = var.create_security_group ? local.allowed_ipv6_cidr_map : {}

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
  cidr_ipv6         = each.value
  description       = "Allow DB access from IPv6 CIDR ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "security_group" {
  for_each = var.create_security_group ? local.allowed_sg_map : {}

  security_group_id            = aws_security_group.this[0].id
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  referenced_security_group_id = each.value
  description                  = "Allow DB access from security group ${each.value}"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  count = var.create_security_group && var.allow_all_outbound ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound IPv4 traffic"
}

resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name   = local.parameter_group_name
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method == null ? null : lower(parameter.value.apply_method)
    }
  }

  tags = merge(local.common_tags, var.parameter_group_tags, {
    Name = local.parameter_group_name
  })
}

resource "aws_rds_cluster" "this" {
  cluster_identifier                  = local.identifier
  engine                              = local.cluster_engine
  engine_version                      = var.engine_version
  database_name                       = var.db_name
  master_username                     = var.username
  manage_master_user_password         = var.manage_master_user_password
  master_password                     = var.manage_master_user_password ? null : var.master_password
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  port                                = var.port
  db_subnet_group_name                = local.resolved_db_subnet_group_name
  vpc_security_group_ids              = local.resolved_vpc_security_group_ids
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.backup_window
  preferred_maintenance_window        = var.maintenance_window
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  apply_immediately                   = var.apply_immediately
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  tags = merge(local.common_tags, var.instance_tags, {
    Name = local.identifier
  })
}

resource "aws_rds_cluster_instance" "writer" {
  identifier                            = local.writer_instance_identifier
  cluster_identifier                    = aws_rds_cluster.this.id
  instance_class                        = var.instance_class
  engine                                = aws_rds_cluster.this.engine
  engine_version                        = var.engine_version
  db_parameter_group_name               = local.resolved_parameter_group_name
  publicly_accessible                   = var.publicly_accessible
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval == 0 ? null : var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  ca_cert_identifier                    = var.ca_cert_identifier
  apply_immediately                     = var.apply_immediately
  promotion_tier                        = 0

  tags = merge(local.common_tags, var.instance_tags, {
    Name = local.writer_instance_identifier
    Role = "writer"
  })
}

resource "aws_rds_cluster_instance" "reader" {
  count = var.create_reader_instance ? 1 : 0

  identifier                            = local.reader_instance_identifier
  cluster_identifier                    = aws_rds_cluster.this.id
  instance_class                        = var.instance_class
  engine                                = aws_rds_cluster.this.engine
  engine_version                        = var.engine_version
  db_parameter_group_name               = local.resolved_parameter_group_name
  publicly_accessible                   = var.publicly_accessible
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval == 0 ? null : var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  ca_cert_identifier                    = var.ca_cert_identifier
  apply_immediately                     = var.apply_immediately
  promotion_tier                        = var.reader_promotion_tier

  tags = merge(local.common_tags, var.instance_tags, {
    Name = local.reader_instance_identifier
    Role = "reader"
  })
}
