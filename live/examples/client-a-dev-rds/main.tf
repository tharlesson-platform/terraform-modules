locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "rds"
  })

  resolved_monitoring_role_arn = var.monitoring_interval > 0 ? coalesce(var.monitoring_role_arn, try(aws_iam_role.enhanced_monitoring[0].arn, null)) : null
  resolved_kms_key_id          = coalesce(var.kms_key_id, try(aws_kms_key.rds_storage[0].arn, null))
  resolved_secret_kms_key_id   = coalesce(var.master_user_secret_kms_key_id, try(aws_kms_key.rds_master_secret[0].arn, null))
  resolved_pi_kms_key_id       = coalesce(var.performance_insights_kms_key_id, local.resolved_kms_key_id)
}

data "aws_iam_policy_document" "enhanced_monitoring_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 && var.create_enhanced_monitoring_role ? 1 : 0

  name               = coalesce(var.enhanced_monitoring_role_name, "${var.client}-${var.environment}-rds-enhanced-monitoring-role")
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_assume_role.json

  tags = merge(local.common_tags, {
    Name = coalesce(var.enhanced_monitoring_role_name, "${var.client}-${var.environment}-rds-enhanced-monitoring-role")
  })
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 && var.create_enhanced_monitoring_role ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_kms_key" "rds_storage" {
  count = var.create_custom_kms_keys ? 1 : 0

  description             = "KMS key for RDS storage encryption (${var.client}-${var.environment})"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation

  tags = merge(local.common_tags, {
    Name    = "${var.client}-${var.environment}-rds-storage-kms"
    Purpose = "rds-storage-encryption"
  })
}

resource "aws_kms_alias" "rds_storage" {
  count = var.create_custom_kms_keys ? 1 : 0

  name          = "alias/${var.client}/${var.environment}/rds-storage"
  target_key_id = aws_kms_key.rds_storage[0].key_id
}

resource "aws_kms_key" "rds_master_secret" {
  count = var.create_custom_kms_keys ? 1 : 0

  description             = "KMS key for RDS master secret encryption (${var.client}-${var.environment})"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation

  tags = merge(local.common_tags, {
    Name    = "${var.client}-${var.environment}-rds-master-secret-kms"
    Purpose = "rds-master-secret-encryption"
  })
}

resource "aws_kms_alias" "rds_master_secret" {
  count = var.create_custom_kms_keys ? 1 : 0

  name          = "alias/${var.client}/${var.environment}/rds-master-secret"
  target_key_id = aws_kms_key.rds_master_secret[0].key_id
}

module "rds" {
  source = "../../../modules/rds"

  name       = "${var.client}-${var.environment}-app-db"
  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  create_reader_instance     = var.create_reader_instance
  reader_instance_identifier = var.reader_instance_identifier

  db_name  = var.db_name
  username = var.username

  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.manage_master_user_password ? local.resolved_secret_kms_key_id : null
  master_password               = var.master_password
  port                          = var.port

  publicly_accessible = var.publicly_accessible

  vpc_id                      = var.vpc_id
  create_db_subnet_group      = var.create_db_subnet_group
  db_subnet_group_name        = var.db_subnet_group_name
  db_subnet_group_subnet_ids  = var.db_subnet_group_subnet_ids
  subnet_tier_tag_key         = var.subnet_tier_tag_key
  database_subnet_tier_values = var.database_subnet_tier_values
  private_subnet_tier_values  = var.private_subnet_tier_values

  create_security_group      = var.create_security_group
  security_group_ids         = var.security_group_ids
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  deletion_protection     = var.deletion_protection
  apply_immediately       = var.apply_immediately

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  storage_encrypted = var.storage_encrypted
  kms_key_id        = local.resolved_kms_key_id

  create_parameter_group = var.create_parameter_group
  parameter_group_family = var.parameter_group_family
  parameters             = var.parameters

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = local.resolved_monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? local.resolved_pi_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_retention_period
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade

  tags = local.common_tags
}

output "rds_endpoint" {
  value = module.rds.cluster_endpoint
}

output "rds_reader_endpoint" {
  value = module.rds.cluster_reader_endpoint
}

output "rds_port" {
  value = module.rds.cluster_port
}

output "rds_cluster_id" {
  value = module.rds.cluster_id
}

output "rds_writer_instance_id" {
  value = module.rds.writer_instance_id
}

output "rds_reader_instance_ids" {
  value = module.rds.reader_instance_ids
}

output "rds_subnet_group_name" {
  value = module.rds.db_subnet_group_name
}

output "discovered_subnet_ids" {
  value = module.rds.discovered_subnet_ids
}

output "selected_subnet_source" {
  value = module.rds.selected_subnet_source
}

output "rds_security_group_ids" {
  value = module.rds.security_group_ids
}

output "master_user_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "enhanced_monitoring_role_arn" {
  value = local.resolved_monitoring_role_arn
}

output "rds_storage_kms_key_arn" {
  value = local.resolved_kms_key_id
}

output "rds_master_secret_kms_key_arn" {
  value = local.resolved_secret_kms_key_id
}
