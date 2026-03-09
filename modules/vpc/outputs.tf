output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block configured in the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway, if created."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value = [
    for key in sort(keys(aws_subnet.public)) : aws_subnet.public[key].id
  ]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value = [
    for key in sort(keys(aws_subnet.private)) : aws_subnet.private[key].id
  ]
}

output "database_subnet_ids" {
  description = "List of database subnet IDs."
  value = [
    for key in sort(keys(aws_subnet.database)) : aws_subnet.database[key].id
  ]
}

output "public_route_table_id" {
  description = "Public route table ID, if created."
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  description = "List of private route table IDs."
  value = [
    for key in sort(keys(aws_route_table.private)) : aws_route_table.private[key].id
  ]
}

output "database_route_table_ids" {
  description = "List of database route table IDs."
  value = [
    for key in sort(keys(aws_route_table.database)) : aws_route_table.database[key].id
  ]
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "Public IP addresses from NAT EIPs."
  value       = aws_eip.nat[*].public_ip
}

output "database_subnet_group_name" {
  description = "DB subnet group name, if created."
  value       = try(aws_db_subnet_group.this[0].name, null)
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway endpoint ID, if created."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "dynamodb_gateway_endpoint_id" {
  description = "DynamoDB Gateway endpoint ID, if created."
  value       = try(aws_vpc_endpoint.dynamodb[0].id, null)
}

output "flow_log_id" {
  description = "VPC Flow Log ID, if enabled."
  value       = try(aws_flow_log.this[0].id, null)
}

output "default_security_group_id" {
  description = "Default security group ID, if managed by this module."
  value       = try(aws_default_security_group.this[0].id, null)
}