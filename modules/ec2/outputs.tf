output "ec2_instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "ec2_instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "ec2_instance_state" {
  description = "Current state of the EC2 instance."
  value       = aws_instance.this.instance_state
}

output "ec2_instance_ami" {
  description = "AMI ID used by the instance."
  value       = aws_instance.this.ami
}

output "ec2_instance_type" {
  description = "Instance type used by EC2."
  value       = aws_instance.this.instance_type
}

output "ec2_instance_availability_zone" {
  description = "Availability zone where instance is running."
  value       = aws_instance.this.availability_zone
}

output "ec2_primary_network_interface_id" {
  description = "Primary ENI ID attached to EC2 instance."
  value       = aws_instance.this.primary_network_interface_id
}

output "resolved_subnet_id" {
  description = "Subnet ID used to launch the instance (explicit or auto-discovered)."
  value       = local.resolved_subnet_id
}

output "resolved_subnet_vpc_id" {
  description = "VPC ID of the resolved subnet."
  value       = try(data.aws_subnet.selected[0].vpc_id, null)
}

output "discovered_private_subnet_ids" {
  description = "Private subnet IDs discovered when subnet_id is null."
  value       = local.discovered_private_subnet_ids
}

output "ec2_private_ip" {
  description = "Private IPv4 address of the instance."
  value       = aws_instance.this.private_ip
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the instance, if assigned."
  value       = aws_instance.this.public_ip
}

output "ec2_private_dns" {
  description = "Private DNS name of the instance."
  value       = aws_instance.this.private_dns
}

output "ec2_public_dns" {
  description = "Public DNS name of the instance, if assigned."
  value       = aws_instance.this.public_dns
}

output "ec2_security_group_ids" {
  description = "Security groups attached to EC2 instance."
  value       = local.resolved_security_group_ids
}

output "created_security_group_id" {
  description = "Created security group ID, if create_security_group is true."
  value       = try(aws_security_group.this[0].id, null)
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to EC2 instance."
  value       = local.resolved_iam_instance_profile
}

output "created_iam_role_name" {
  description = "Created IAM role name, if create_instance_profile is true."
  value       = try(aws_iam_role.this[0].name, null)
}

output "key_pair_name" {
  description = "Key pair name attached to EC2 instance."
  value       = local.resolved_key_name
}

output "elastic_ip_allocation_id" {
  description = "Associated EIP allocation ID, if associate_eip is true."
  value       = var.associate_eip ? coalesce(var.eip_allocation_id, aws_eip.this[0].id) : null
}

output "elastic_ip_public_ip" {
  description = "Associated EIP public IPv4, if associate_eip is true."
  value = var.associate_eip ? coalesce(
    try(aws_eip.this[0].public_ip, null),
    try(data.aws_eip.existing[0].public_ip, null)
  ) : null
}
