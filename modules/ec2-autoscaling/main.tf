data "aws_subnets" "private" {
  count = length(var.subnet_ids) == 0 && var.vpc_id != null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:${var.private_subnet_tag_key}"
    values = var.private_subnet_tag_values
  }
}

data "aws_ssm_parameter" "ami" {
  count = var.ami_id == null && var.resolve_ami_from_ssm ? 1 : 0

  name = var.ami_ssm_parameter_name
}

locals {
  instance_name          = coalesce(var.instance_name, var.name)
  launch_template_name   = coalesce(var.launch_template_name, "${var.name}-lt")
  autoscaling_group_name = coalesce(var.autoscaling_group_name, "${var.name}-asg")
  security_group_name    = coalesce(var.security_group_name, "${var.name}-asg-sg")
  iam_role_name          = coalesce(var.iam_role_name, "${var.name}-asg-role")
  instance_profile_name  = coalesce(var.instance_profile_name, "${var.name}-asg-profile")

  discovered_private_subnet_ids = length(var.subnet_ids) == 0 ? sort(try(data.aws_subnets.private[0].ids, [])) : []
  resolved_subnet_ids           = length(var.subnet_ids) > 0 ? var.subnet_ids : local.discovered_private_subnet_ids

  resolved_ami_id               = coalesce(var.ami_id, try(data.aws_ssm_parameter.ami[0].value, null))
  resolved_iam_instance_profile = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name

  resolved_security_group_ids = compact(concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.vpc_security_group_ids
  ))

  effective_egress_rules = (
    var.create_security_group ? (
      length(var.security_group_egress_rules) > 0 ? var.security_group_egress_rules : [
        {
          description = "Allow all outbound traffic"
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
    ) : []
  )

  ingress_rules_ipv4 = {
    for index, rule in var.security_group_ingress_rules :
    tostring(index) => rule
    if var.create_security_group && try(rule.cidr_ipv4, null) != null
  }

  ingress_rules_ipv6 = {
    for index, rule in var.security_group_ingress_rules :
    tostring(index) => rule
    if var.create_security_group && try(rule.cidr_ipv6, null) != null
  }

  ingress_rules_prefix_list = {
    for index, rule in var.security_group_ingress_rules :
    tostring(index) => rule
    if var.create_security_group && try(rule.prefix_list_id, null) != null
  }

  ingress_rules_referenced_security_group = {
    for index, rule in var.security_group_ingress_rules :
    tostring(index) => rule
    if var.create_security_group && try(rule.referenced_security_group_id, null) != null
  }

  egress_rules_ipv4 = {
    for index, rule in local.effective_egress_rules :
    tostring(index) => rule
    if try(rule.cidr_ipv4, null) != null
  }

  egress_rules_ipv6 = {
    for index, rule in local.effective_egress_rules :
    tostring(index) => rule
    if try(rule.cidr_ipv6, null) != null
  }

  egress_rules_prefix_list = {
    for index, rule in local.effective_egress_rules :
    tostring(index) => rule
    if try(rule.prefix_list_id, null) != null
  }

  egress_rules_referenced_security_group = {
    for index, rule in local.effective_egress_rules :
    tostring(index) => rule
    if try(rule.referenced_security_group_id, null) != null
  }

  launch_template_user_data = var.user_data_base64 != null ? var.user_data_base64 : (
    var.user_data != null ? base64encode(var.user_data) : null
  )

  launch_template_instance_tags = merge(local.common_tags, var.instance_tags, {
    Name = local.instance_name
  })

  launch_template_volume_tags = merge(local.common_tags, var.volume_tags, {
    Name = "${local.instance_name}-volume"
  })

  autoscaling_group_tags = merge(local.common_tags, var.autoscaling_group_tags, {
    Name = local.instance_name
  })

  target_tracking_policies_by_name = {
    for policy in var.target_tracking_policies :
    policy.name => policy
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "ec2-autoscaling"
    Workload  = var.name
  })
}

check "ami_input_is_consistent" {
  assert {
    condition     = var.ami_id != null || var.resolve_ami_from_ssm
    error_message = "Set ami_id or enable resolve_ami_from_ssm."
  }
}

check "subnet_selection_input_is_consistent" {
  assert {
    condition     = length(var.subnet_ids) > 0 || var.vpc_id != null
    error_message = "Provide subnet_ids, or set vpc_id to enable private subnet auto-discovery."
  }
}

check "private_subnet_auto_discovery_found_results" {
  assert {
    condition     = length(var.subnet_ids) > 0 || length(local.discovered_private_subnet_ids) > 0
    error_message = "No private subnets were found. Check vpc_id and private_subnet_tag_key/private_subnet_tag_values."
  }
}

check "user_data_mode_is_exclusive" {
  assert {
    condition     = !(var.user_data != null && var.user_data_base64 != null)
    error_message = "user_data and user_data_base64 cannot both be set."
  }
}

check "security_group_inputs_are_consistent" {
  assert {
    condition = var.create_security_group ? (
      var.vpc_id != null
      ) : (
      length(var.vpc_security_group_ids) > 0
    )
    error_message = "When create_security_group is true, set vpc_id. When false, provide at least one security group ID in vpc_security_group_ids."
  }
}

check "security_group_rules_require_created_group" {
  assert {
    condition     = var.create_security_group || (length(var.security_group_ingress_rules) == 0 && length(var.security_group_egress_rules) == 0)
    error_message = "security_group_ingress_rules and security_group_egress_rules can only be used when create_security_group is true."
  }
}

check "ingress_rule_sources_are_exclusive" {
  assert {
    condition = alltrue([
      for rule in var.security_group_ingress_rules :
      length(compact([
        try(rule.cidr_ipv4, null),
        try(rule.cidr_ipv6, null),
        try(rule.prefix_list_id, null),
        try(rule.referenced_security_group_id, null)
      ])) == 1
    ])
    error_message = "Each security_group_ingress_rules item must set exactly one source: cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id."
  }
}

check "egress_rule_sources_are_exclusive" {
  assert {
    condition = alltrue([
      for rule in var.security_group_egress_rules :
      length(compact([
        try(rule.cidr_ipv4, null),
        try(rule.cidr_ipv6, null),
        try(rule.prefix_list_id, null),
        try(rule.referenced_security_group_id, null)
      ])) == 1
    ])
    error_message = "Each security_group_egress_rules item must set exactly one source: cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id."
  }
}

check "security_group_rule_ports_are_consistent" {
  assert {
    condition = alltrue([
      for rule in concat(var.security_group_ingress_rules, var.security_group_egress_rules) :
      rule.ip_protocol == "-1" ? (
        try(rule.from_port, null) == null && try(rule.to_port, null) == null
        ) : (
        try(rule.from_port, null) != null && try(rule.to_port, null) != null
      )
    ])
    error_message = "For security group rules: set from_port/to_port when ip_protocol is not -1; omit both when ip_protocol is -1."
  }
}

check "instance_profile_inputs_are_consistent" {
  assert {
    condition = var.create_instance_profile ? (
      var.iam_instance_profile_name == null
      ) : (
      length(var.iam_role_policy_arns) == 0 && var.iam_role_name == null && var.instance_profile_name == null
    )
    error_message = "When create_instance_profile is true, do not set iam_instance_profile_name. When false, do not set iam_role_name, instance_profile_name, or iam_role_policy_arns."
  }
}

check "autoscaling_capacity_is_consistent" {
  assert {
    condition     = var.min_size <= var.desired_capacity && var.desired_capacity <= var.max_size
    error_message = "Capacity values must respect min_size <= desired_capacity <= max_size."
  }
}

check "target_tracking_policy_names_are_unique" {
  assert {
    condition     = length(var.target_tracking_policies) == length(keys(local.target_tracking_policies_by_name))
    error_message = "target_tracking_policies names must be unique."
  }
}

check "target_tracking_resource_label_is_consistent" {
  assert {
    condition = alltrue([
      for policy in var.target_tracking_policies :
      coalesce(try(policy.predefined_metric_type, null), "ASGAverageCPUUtilization") == "ALBRequestCountPerTarget" ? (
        try(policy.resource_label, null) != null
        ) : (
        try(policy.resource_label, null) == null
      )
    ])
    error_message = "resource_label is required only when predefined_metric_type is ALBRequestCountPerTarget."
  }
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name                   = local.security_group_name
  description            = var.security_group_description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true
  ingress                = []
  egress                 = []

  tags = merge(local.common_tags, var.security_group_tags, {
    Name = local.security_group_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "ipv4" {
  for_each = local.ingress_rules_ipv4

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_ingress_rule" "ipv6" {
  for_each = local.ingress_rules_ipv6

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  cidr_ipv6         = each.value.cidr_ipv6
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_ingress_rule" "prefix_list" {
  for_each = local.ingress_rules_prefix_list

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  prefix_list_id    = each.value.prefix_list_id
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_ingress_rule" "referenced_security_group" {
  for_each = local.ingress_rules_referenced_security_group

  security_group_id            = aws_security_group.this[0].id
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.ip_protocol == "-1" ? null : each.value.to_port
  referenced_security_group_id = each.value.referenced_security_group_id
  description                  = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "ipv4" {
  for_each = local.egress_rules_ipv4

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "ipv6" {
  for_each = local.egress_rules_ipv6

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  cidr_ipv6         = each.value.cidr_ipv6
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "prefix_list" {
  for_each = local.egress_rules_prefix_list

  security_group_id = aws_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port
  prefix_list_id    = each.value.prefix_list_id
  description       = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "referenced_security_group" {
  for_each = local.egress_rules_referenced_security_group

  security_group_id            = aws_security_group.this[0].id
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.ip_protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.ip_protocol == "-1" ? null : each.value.to_port
  referenced_security_group_id = each.value.referenced_security_group_id
  description                  = try(each.value.description, null)
}

data "aws_iam_policy_document" "ec2_assume_role" {
  count = var.create_instance_profile ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_instance_profile ? 1 : 0

  name                 = local.iam_role_name
  path                 = var.iam_role_path
  description          = var.iam_role_description
  assume_role_policy   = data.aws_iam_policy_document.ec2_assume_role[0].json
  permissions_boundary = var.iam_role_permissions_boundary

  tags = merge(local.common_tags, var.iam_role_tags, {
    Name = local.iam_role_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create_instance_profile ? toset(var.iam_role_policy_arns) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = local.instance_profile_name
  role = aws_iam_role.this[0].name

  tags = merge(local.common_tags, var.instance_profile_tags, {
    Name = local.instance_profile_name
  })
}

resource "aws_launch_template" "this" {
  name                   = local.launch_template_name
  image_id               = local.resolved_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  ebs_optimized          = var.ebs_optimized
  update_default_version = true
  user_data              = local.launch_template_user_data

  vpc_security_group_ids = local.resolved_security_group_ids

  dynamic "iam_instance_profile" {
    for_each = local.resolved_iam_instance_profile == null ? [] : [local.resolved_iam_instance_profile]
    content {
      name = iam_instance_profile.value
    }
  }

  monitoring {
    enabled = var.detailed_monitoring
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  dynamic "block_device_mappings" {
    for_each = var.root_block_device == null ? [] : [var.root_block_device]
    content {
      device_name = var.root_device_name
      ebs {
        volume_type           = try(block_device_mappings.value.volume_type, null)
        volume_size           = try(block_device_mappings.value.volume_size, null)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.ebs_block_devices
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)

      dynamic "ebs" {
        for_each = try(block_device_mappings.value.no_device, null) != null || try(block_device_mappings.value.virtual_name, null) != null ? [] : [1]
        content {
          volume_type           = try(block_device_mappings.value.volume_type, null)
          volume_size           = try(block_device_mappings.value.volume_size, null)
          iops                  = try(block_device_mappings.value.iops, null)
          throughput            = try(block_device_mappings.value.throughput, null)
          encrypted             = try(block_device_mappings.value.encrypted, true)
          kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
          snapshot_id           = try(block_device_mappings.value.snapshot_id, null)
          delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        }
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.launch_template_instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.launch_template_volume_tags
  }

  tags = merge(local.common_tags, var.launch_template_tags, {
    Name = local.launch_template_name
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_vpc_security_group_ingress_rule.ipv4,
    aws_vpc_security_group_ingress_rule.ipv6,
    aws_vpc_security_group_ingress_rule.prefix_list,
    aws_vpc_security_group_ingress_rule.referenced_security_group,
    aws_vpc_security_group_egress_rule.ipv4,
    aws_vpc_security_group_egress_rule.ipv6,
    aws_vpc_security_group_egress_rule.prefix_list,
    aws_vpc_security_group_egress_rule.referenced_security_group,
    aws_iam_role_policy_attachment.this
  ]
}

resource "aws_autoscaling_group" "this" {
  name                      = local.autoscaling_group_name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = local.resolved_subnet_ids
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
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = length(var.enabled_metrics) > 0 ? var.metrics_granularity : null

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.autoscaling_group_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count = var.cpu_target_tracking_enabled ? 1 : 0

  name                      = "${local.autoscaling_group_name}-cpu-target"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.this.name
  estimated_instance_warmup = var.cpu_target_tracking_estimated_instance_warmup

  target_tracking_configuration {
    target_value     = var.cpu_target_tracking_target_value
    disable_scale_in = var.cpu_target_tracking_disable_scale_in

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_autoscaling_policy" "target_tracking" {
  for_each = local.target_tracking_policies_by_name

  name                      = each.value.name
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.this.name
  estimated_instance_warmup = try(each.value.estimated_instance_warmup, null)

  target_tracking_configuration {
    target_value     = each.value.target_value
    disable_scale_in = try(each.value.disable_scale_in, false)

    predefined_metric_specification {
      predefined_metric_type = coalesce(try(each.value.predefined_metric_type, null), "ASGAverageCPUUtilization")
      resource_label         = try(each.value.resource_label, null)
    }
  }
}
