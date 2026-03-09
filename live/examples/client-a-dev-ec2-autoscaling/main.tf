locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "ec2-autoscaling"
  })
}

module "ec2_autoscaling" {
  source = "../../../modules/ec2-autoscaling"

  name          = "${var.client}-${var.environment}-${var.workload_name}"
  instance_name = var.instance_name
  instance_type = var.instance_type

  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id

  private_subnet_tag_key    = var.private_subnet_tag_key
  private_subnet_tag_values = var.private_subnet_tag_values

  ami_id                 = var.ami_id
  resolve_ami_from_ssm   = var.resolve_ami_from_ssm
  ami_ssm_parameter_name = var.ami_ssm_parameter_name

  key_name            = var.key_name
  ebs_optimized       = var.ebs_optimized
  detailed_monitoring = var.detailed_monitoring

  user_data        = coalesce(var.user_data, file("${path.module}/cloudwatch-detailed-monitoring.sh"))
  user_data_base64 = var.user_data_base64

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

  root_block_device = var.root_block_device
  ebs_block_devices = var.ebs_block_devices

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown

  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  protect_from_scale_in     = var.protect_from_scale_in
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  force_delete              = var.force_delete
  capacity_rebalance        = var.capacity_rebalance
  max_instance_lifetime     = var.max_instance_lifetime

  enabled_metrics     = var.enabled_metrics
  metrics_granularity = var.metrics_granularity

  cpu_target_tracking_enabled                   = var.cpu_target_tracking_enabled
  cpu_target_tracking_target_value              = var.cpu_target_tracking_target_value
  cpu_target_tracking_disable_scale_in          = var.cpu_target_tracking_disable_scale_in
  cpu_target_tracking_estimated_instance_warmup = var.cpu_target_tracking_estimated_instance_warmup
  target_tracking_policies                      = var.target_tracking_policies

  tags = local.common_tags
}

output "autoscaling_group_name" {
  value = module.ec2_autoscaling.autoscaling_group_name
}

output "autoscaling_group_arn" {
  value = module.ec2_autoscaling.autoscaling_group_arn
}

output "launch_template_id" {
  value = module.ec2_autoscaling.launch_template_id
}

output "resolved_subnet_ids" {
  value = module.ec2_autoscaling.resolved_subnet_ids
}

output "resolved_security_group_ids" {
  value = module.ec2_autoscaling.resolved_security_group_ids
}

output "iam_instance_profile_name" {
  value = module.ec2_autoscaling.iam_instance_profile_name
}

output "cpu_target_tracking_policy_arn" {
  value = module.ec2_autoscaling.cpu_target_tracking_policy_arn
}
