region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-rds-client-a-dev"

client      = "client-a"
environment = "dev"

# Sem subnet_id manual: modulo descobre subnets por tag e cria subnet group automaticamente.
vpc_id                     = "vpc-0123456789abcdef0"
db_subnet_group_name       = null
create_db_subnet_group     = true
db_subnet_group_subnet_ids = []

allowed_cidr_blocks        = ["10.50.10.0/24", "10.50.11.0/24", "10.50.12.0/24"]
allowed_security_group_ids = []

engine         = "aurora-postgresql"
engine_version = null
instance_class = "db.t4g.medium"

create_reader_instance     = false
reader_instance_identifier = null

db_name  = "appdb"
username = "appadmin"

manage_master_user_password = true
port                        = 5432
publicly_accessible         = false

storage_encrypted               = true
create_custom_kms_keys          = false
kms_key_id                      = null
master_user_secret_kms_key_id   = null
performance_insights_kms_key_id = null
kms_deletion_window_in_days     = 30
kms_enable_key_rotation         = true

multi_az                = false
backup_retention_period = 7
deletion_protection     = false
apply_immediately       = true

skip_final_snapshot       = true
final_snapshot_identifier = null

auto_minor_version_upgrade = true

create_parameter_group = false
parameter_group_family = null
parameters             = []

enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
monitoring_interval             = 0
create_enhanced_monitoring_role = true
monitoring_role_arn             = null
enhanced_monitoring_role_name   = null

performance_insights_enabled          = false
performance_insights_retention_period = 7

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}
