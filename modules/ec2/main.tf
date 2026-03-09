data "aws_subnets" "private" {
  count = var.subnet_id == null && var.vpc_id != null ? 1 : 0

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

data "aws_eip" "existing" {
  count = var.associate_eip && var.eip_allocation_id != null ? 1 : 0

  id = var.eip_allocation_id
}

locals {
  instance_name         = coalesce(var.instance_name, var.name)
  security_group_name   = coalesce(var.security_group_name, "${local.instance_name}-ec2-sg")
  iam_role_name         = coalesce(var.iam_role_name, "${local.instance_name}-ec2-role")
  instance_profile_name = coalesce(var.instance_profile_name, "${local.instance_name}-ec2-profile")

  discovered_private_subnet_ids = var.subnet_id == null ? sort(try(data.aws_subnets.private[0].ids, [])) : []
  resolved_subnet_id            = coalesce(var.subnet_id, try(local.discovered_private_subnet_ids[0], null))

  resolved_ami_id               = coalesce(var.ami_id, try(data.aws_ssm_parameter.ami[0].value, null))
  resolved_key_name             = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name
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

  common_tags = merge(var.tags, {
    ManagedBy    = "Terraform"
    Module       = "ec2"
    InstanceName = local.instance_name
  })
}

data "aws_subnet" "selected" {
  count = local.resolved_subnet_id == null ? 0 : 1

  id = local.resolved_subnet_id
}

check "ami_input_is_consistent" {
  assert {
    condition     = var.ami_id != null || var.resolve_ami_from_ssm
    error_message = "Set ami_id or enable resolve_ami_from_ssm."
  }
}

check "subnet_selection_input_is_consistent" {
  assert {
    condition     = var.subnet_id != null || var.vpc_id != null
    error_message = "Provide subnet_id, or set vpc_id to enable private subnet auto-discovery."
  }
}

check "private_subnet_auto_discovery_found_results" {
  assert {
    condition     = var.subnet_id != null || length(local.discovered_private_subnet_ids) > 0
    error_message = "No private subnets were found. Check vpc_id and private_subnet_tag_key/private_subnet_tag_values."
  }
}

check "subnet_and_vpc_are_consistent" {
  assert {
    condition     = var.subnet_id == null || var.vpc_id == null || try(data.aws_subnet.selected[0].vpc_id, null) == var.vpc_id
    error_message = "subnet_id does not belong to the provided vpc_id."
  }
}

check "user_data_mode_is_exclusive" {
  assert {
    condition     = !(var.user_data != null && var.user_data_base64 != null)
    error_message = "user_data and user_data_base64 cannot both be set."
  }
}

check "key_pair_inputs_are_consistent" {
  assert {
    condition     = var.create_key_pair ? (var.key_name == null && var.key_pair_name != null && var.public_key != null) : true
    error_message = "When create_key_pair is true, set key_pair_name and public_key, and leave key_name as null."
  }
}

check "security_group_inputs_are_consistent" {
  assert {
    condition     = var.create_security_group || length(var.vpc_security_group_ids) > 0
    error_message = "When create_security_group is false, provide at least one security group ID in vpc_security_group_ids."
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

check "cpu_threads_require_cpu_cores" {
  assert {
    condition     = var.cpu_threads_per_core == null || var.cpu_core_count != null
    error_message = "cpu_core_count must be provided when cpu_threads_per_core is set."
  }
}

check "ipv6_mode_is_exclusive" {
  assert {
    condition     = var.ipv6_address_count == null || length(var.ipv6_addresses) == 0
    error_message = "Use either ipv6_address_count or ipv6_addresses, not both."
  }
}

check "root_iops_storage_type_is_consistent" {
  assert {
    condition     = var.root_iops == null || try(contains(["gp3", "io1", "io2"], coalesce(var.root_volume_type, "gp3")), false)
    error_message = "root_iops can only be configured with root_volume_type gp3, io1, or io2."
  }
}

check "root_throughput_requires_gp3" {
  assert {
    condition     = var.root_throughput == null || try(coalesce(var.root_volume_type, "gp3") == "gp3", false)
    error_message = "root_throughput can only be configured when root_volume_type is gp3."
  }
}

check "eip_inputs_are_consistent" {
  assert {
    condition     = var.associate_eip || var.eip_allocation_id == null
    error_message = "eip_allocation_id requires associate_eip = true."
  }
}

resource "aws_key_pair" "this" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.key_pair_name
  public_key = var.public_key

  tags = merge(local.common_tags, var.key_pair_tags, {
    Name = var.key_pair_name
  })
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name                   = local.security_group_name
  description            = var.security_group_description
  vpc_id                 = coalesce(var.vpc_id, try(data.aws_subnet.selected[0].vpc_id, null))
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

resource "aws_instance" "this" {
  ami           = local.resolved_ami_id
  instance_type = var.instance_type
  subnet_id     = local.resolved_subnet_id

  availability_zone           = var.availability_zone
  key_name                    = local.resolved_key_name
  iam_instance_profile        = local.resolved_iam_instance_profile
  vpc_security_group_ids      = local.resolved_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  source_dest_check                    = var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  monitoring                           = var.monitoring
  ebs_optimized                        = var.ebs_optimized
  tenancy                              = var.tenancy
  hibernation                          = var.hibernation

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_metadata_tags
  }

  dynamic "credit_specification" {
    for_each = var.cpu_credits == null ? [] : [var.cpu_credits]
    content {
      cpu_credits = credit_specification.value
    }
  }

  dynamic "cpu_options" {
    for_each = var.cpu_core_count == null && var.cpu_threads_per_core == null ? [] : [1]
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  }

  dynamic "root_block_device" {
    for_each = var.manage_root_block_device ? [1] : []
    content {
      volume_type           = coalesce(var.root_volume_type, "gp3")
      volume_size           = var.root_volume_size
      iops                  = var.root_iops
      throughput            = var.root_throughput
      encrypted             = var.root_encrypted
      kms_key_id            = var.root_kms_key_id
      delete_on_termination = var.root_delete_on_termination

      tags = merge(local.common_tags, var.root_volume_tags, {
        Name = "${local.instance_name}-root"
      })
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = try(ebs_block_device.value.volume_size, null)
      volume_type           = try(ebs_block_device.value.volume_type, null)
      iops                  = try(ebs_block_device.value.iops, null)
      throughput            = try(ebs_block_device.value.throughput, null)
      encrypted             = try(ebs_block_device.value.encrypted, null)
      kms_key_id            = try(ebs_block_device.value.kms_key_id, null)
      snapshot_id           = try(ebs_block_device.value.snapshot_id, null)
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, true)

      tags = merge(local.common_tags, try(ebs_block_device.value.tags, {}), {
        Name = "${local.instance_name}-${replace(ebs_block_device.value.device_name, "/dev/", "")}"
      })
    }
  }

  volume_tags = merge(local.common_tags, var.volume_tags, {
    Name = "${local.instance_name}-volume"
  })

  tags = merge(local.common_tags, var.instance_tags, {
    Name = local.instance_name
  })

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

resource "aws_eip" "this" {
  count = var.associate_eip && var.eip_allocation_id == null ? 1 : 0

  domain = "vpc"

  tags = merge(local.common_tags, var.eip_tags, {
    Name = "${local.instance_name}-eip"
  })
}

resource "aws_eip_association" "this" {
  count = var.associate_eip ? 1 : 0

  instance_id   = aws_instance.this.id
  allocation_id = coalesce(var.eip_allocation_id, aws_eip.this[0].id)
}
