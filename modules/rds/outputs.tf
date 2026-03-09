output "cluster_id" {
  description = "ID of the RDS cluster."
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the RDS cluster."
  value       = aws_rds_cluster.this.arn
}

output "cluster_identifier" {
  description = "Identifier of the RDS cluster."
  value       = aws_rds_cluster.this.cluster_identifier
}

output "cluster_endpoint" {
  description = "Writer endpoint of the RDS cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint of the RDS cluster."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "cluster_port" {
  description = "Port where the cluster listens."
  value       = aws_rds_cluster.this.port
}

output "cluster_engine" {
  description = "Engine configured in the cluster."
  value       = aws_rds_cluster.this.engine
}

output "cluster_engine_version" {
  description = "Engine version configured in the cluster."
  value       = aws_rds_cluster.this.engine_version
}

output "cluster_status" {
  description = "Current status of the RDS cluster."
  value       = null
}

output "writer_instance_id" {
  description = "ID of the writer cluster instance."
  value       = aws_rds_cluster_instance.writer.id
}

output "writer_instance_arn" {
  description = "ARN of the writer cluster instance."
  value       = aws_rds_cluster_instance.writer.arn
}

output "writer_instance_identifier" {
  description = "Identifier of the writer cluster instance."
  value       = aws_rds_cluster_instance.writer.identifier
}

output "reader_instance_ids" {
  description = "IDs of optional reader cluster instances."
  value       = aws_rds_cluster_instance.reader[*].id
}

output "db_subnet_group_name" {
  description = "Subnet group name attached to RDS cluster."
  value       = local.resolved_db_subnet_group_name
}

output "discovered_subnet_ids" {
  description = "Subnet IDs selected by discovery (database tier first, private fallback)."
  value       = local.discovered_subnet_ids
}

output "selected_subnet_source" {
  description = "Source used to select subnets: provided, database, private, or none."
  value       = local.selected_subnet_source
}

output "security_group_ids" {
  description = "Security groups attached to RDS cluster."
  value       = local.resolved_vpc_security_group_ids
}

output "created_security_group_id" {
  description = "Created security group ID, if create_security_group is true."
  value       = try(aws_security_group.this[0].id, null)
}

output "parameter_group_name" {
  description = "DB parameter group attached to cluster instances."
  value       = local.resolved_parameter_group_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN with master credentials, when managed by RDS."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

# Compatibility outputs for existing stacks that still consume db_instance_* names.
output "db_instance_id" {
  description = "Compatibility output mapped to writer instance ID."
  value       = aws_rds_cluster_instance.writer.id
}

output "db_instance_arn" {
  description = "Compatibility output mapped to writer instance ARN."
  value       = aws_rds_cluster_instance.writer.arn
}

output "db_instance_identifier" {
  description = "Compatibility output mapped to writer instance identifier."
  value       = aws_rds_cluster_instance.writer.identifier
}

output "db_instance_resource_id" {
  description = "Compatibility output mapped to writer instance resource ID."
  value       = try(aws_rds_cluster.this.cluster_resource_id, null)
}

output "db_instance_endpoint" {
  description = "Compatibility output mapped to cluster writer endpoint."
  value       = aws_rds_cluster.this.endpoint
}

output "db_instance_address" {
  description = "Compatibility output mapped to cluster writer address."
  value       = split(":", aws_rds_cluster.this.endpoint)[0]
}

output "db_instance_port" {
  description = "Compatibility output mapped to cluster port."
  value       = aws_rds_cluster.this.port
}

output "db_instance_status" {
  description = "Compatibility output mapped to writer instance status."
  value       = null
}

output "db_name" {
  description = "Database name configured in the cluster."
  value       = aws_rds_cluster.this.database_name
}
