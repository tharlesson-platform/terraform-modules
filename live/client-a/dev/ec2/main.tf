locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "ec2"
  })
}

module "ec2" {
  source = "../../../../modules/ec2"

  name          = "${var.client}-${var.environment}-${var.workload_name}"
  instance_name = var.instance_name
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_id        = var.vpc_id

  private_subnet_tag_key    = var.private_subnet_tag_key
  private_subnet_tag_values = var.private_subnet_tag_values

  ami_id                 = var.ami_id
  resolve_ami_from_ssm   = var.resolve_ami_from_ssm
  ami_ssm_parameter_name = var.ami_ssm_parameter_name

  create_security_group        = var.create_security_group
  security_group_name          = var.security_group_name
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  vpc_security_group_ids       = var.vpc_security_group_ids

  create_instance_profile   = var.create_instance_profile
  iam_instance_profile_name = var.iam_instance_profile_name
  instance_profile_name     = var.instance_profile_name
  iam_role_name             = var.iam_role_name
  iam_role_policy_arns      = var.iam_role_policy_arns

  key_name        = var.key_name
  create_key_pair = var.create_key_pair
  key_pair_name   = var.key_pair_name
  public_key      = var.public_key

  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  monitoring                  = var.monitoring

  user_data                   = coalesce(var.user_data, file("${path.module}/cloudwatch-detailed-monitoring.sh"))
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  manage_root_block_device = var.manage_root_block_device
  root_volume_type         = var.root_volume_type
  root_volume_size         = var.root_volume_size

  ebs_block_devices = var.ebs_block_devices

  associate_eip     = var.associate_eip
  eip_allocation_id = var.eip_allocation_id

  tags = local.common_tags
}

output "ec2_instance_id" {
  value = module.ec2.ec2_instance_id
}

output "ec2_private_ip" {
  value = module.ec2.ec2_private_ip
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "ec2_security_group_ids" {
  value = module.ec2.ec2_security_group_ids
}

output "ec2_iam_instance_profile_name" {
  value = module.ec2.iam_instance_profile_name
}

output "ec2_elastic_ip" {
  value = module.ec2.elastic_ip_public_ip
}

output "ec2_resolved_subnet_id" {
  value = module.ec2.resolved_subnet_id
}

output "ec2_discovered_private_subnet_ids" {
  value = module.ec2.discovered_private_subnet_ids
}

