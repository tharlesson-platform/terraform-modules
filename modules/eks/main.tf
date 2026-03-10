data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_nodes_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_role ? 1 : 0

  name                 = coalesce(var.cluster_role_name, "${var.name}-eks-cluster-role")
  assume_role_policy   = data.aws_iam_policy_document.eks_cluster_assume_role.json
  permissions_boundary = var.cluster_role_permissions_boundary

  tags = merge(local.common_tags, var.cluster_role_tags, {
    Name = coalesce(var.cluster_role_name, "${var.name}-eks-cluster-role")
  })
}

resource "aws_iam_role_policy_attachment" "cluster_default" {
  count = var.create_cluster_role ? 1 : 0

  role       = aws_iam_role.cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_additional" {
  for_each = var.create_cluster_role ? toset(var.cluster_role_policy_arns) : toset([])

  role       = aws_iam_role.cluster[0].name
  policy_arn = each.value
}

resource "aws_iam_role" "node" {
  count = var.create_node_role ? 1 : 0

  name                 = coalesce(var.node_role_name, "${var.name}-eks-node-role")
  assume_role_policy   = data.aws_iam_policy_document.eks_nodes_assume_role.json
  permissions_boundary = var.node_role_permissions_boundary

  tags = merge(local.common_tags, var.node_role_tags, {
    Name = coalesce(var.node_role_name, "${var.name}-eks-node-role")
  })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  count = var.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  count = var.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  count = var.create_node_role ? 1 : 0

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = var.create_node_role ? toset(var.node_role_policy_arns) : toset([])

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

locals {
  cluster_name = coalesce(var.cluster_name, "${var.name}-cluster")

  discovered_log_group_name = coalesce(var.log_group_name, "/aws/eks/${local.cluster_name}/cluster")

  resolved_cluster_role_arn = coalesce(
    try(aws_iam_role.cluster[0].arn, null),
    var.cluster_role_arn
  )

  resolved_node_role_arn = coalesce(
    try(aws_iam_role.node[0].arn, null),
    var.node_role_arn
  )

  resolved_cluster_security_group_id = coalesce(
    try(aws_security_group.cluster[0].id, null),
    var.cluster_security_group_id
  )

  resolved_node_security_group_ids = compact(concat(
    var.create_node_security_group ? [aws_security_group.node[0].id] : [],
    var.node_security_group_ids
  ))

  resolved_cluster_security_group_ids = compact(concat(
    [local.resolved_cluster_security_group_id],
    var.cluster_security_group_additional_ids
  ))

  resolved_alb_security_group_ids = var.enable_ingress_alb && var.create_alb ? (
    var.create_alb_security_group ? [aws_security_group.alb[0].id] : var.alb_security_group_ids
  ) : []

  resolved_ingress_target_group_arn = var.enable_ingress_alb ? coalesce(
    try(module.alb[0].target_group_arn, null),
    var.alb_target_group_arn
  ) : null

  resolved_oidc_thumbprint_list = var.create_oidc_provider ? (
    var.oidc_thumbprint_list != null ? var.oidc_thumbprint_list : [
      data.tls_certificate.cluster_oidc[0].certificates[0].sha1_fingerprint
    ]
  ) : []

  cluster_api_allowed_cidrs_by_index = {
    for index, cidr in var.cluster_endpoint_public_access_cidrs :
    tostring(index) => cidr
  }

  alb_ingress_cidrs_by_index = {
    for index, cidr in var.alb_ingress_cidr_blocks :
    tostring(index) => cidr
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "eks"
    Workload  = var.name
  })
}

check "cluster_role_inputs_are_consistent" {
  assert {
    condition = var.create_cluster_role ? (
      var.cluster_role_arn == null
      ) : (
      var.cluster_role_arn != null
    )
    error_message = "When create_cluster_role is true, keep cluster_role_arn null. When false, set cluster_role_arn."
  }
}

check "node_role_inputs_are_consistent" {
  assert {
    condition = var.create_node_role ? (
      var.node_role_arn == null
      ) : (
      var.node_role_arn != null
    )
    error_message = "When create_node_role is true, keep node_role_arn null. When false, set node_role_arn."
  }
}

check "cluster_security_group_inputs_are_consistent" {
  assert {
    condition = var.create_cluster_security_group ? (
      var.cluster_security_group_id == null
      ) : (
      var.cluster_security_group_id != null
    )
    error_message = "When create_cluster_security_group is true, keep cluster_security_group_id null. When false, set cluster_security_group_id."
  }
}

check "node_security_group_inputs_are_consistent" {
  assert {
    condition = var.create_node_security_group ? (
      true
      ) : (
      length(var.node_security_group_ids) > 0
    )
    error_message = "When create_node_security_group is false, provide at least one node_security_group_ids value."
  }
}

check "cluster_subnet_count_is_valid" {
  assert {
    condition     = length(var.cluster_subnet_ids) >= 2
    error_message = "Provide at least two cluster_subnet_ids values for EKS."
  }
}

check "node_group_subnets_are_resolved" {
  assert {
    condition = alltrue([
      for node_group in values(var.managed_node_groups) :
      (try(node_group.subnet_ids, null) != null && length(node_group.subnet_ids) > 0) || length(var.node_subnet_ids) > 0
    ])
    error_message = "Each managed node group requires subnet_ids or a non-empty global node_subnet_ids list."
  }
}

check "node_group_scaling_bounds_are_consistent" {
  assert {
    condition = alltrue([
      for node_group in values(var.managed_node_groups) :
      node_group.min_size <= node_group.desired_size && node_group.desired_size <= node_group.max_size
    ])
    error_message = "Each managed node group must satisfy min_size <= desired_size <= max_size."
  }
}

check "cluster_endpoint_access_is_enabled" {
  assert {
    condition     = var.cluster_endpoint_private_access || var.cluster_endpoint_public_access
    error_message = "At least one EKS endpoint access mode must be enabled (private or public)."
  }
}

check "ingress_alb_inputs_are_consistent" {
  assert {
    condition = !var.enable_ingress_alb || !var.create_alb || (
      length(var.alb_subnet_ids) >= 2
      && (var.create_alb_security_group || length(var.alb_security_group_ids) > 0)
    )
    error_message = "When enable_ingress_alb and create_alb are true, provide at least two alb_subnet_ids and ALB security groups (created or existing)."
  }
}

check "existing_target_group_is_required_when_alb_is_not_created" {
  assert {
    condition     = !var.enable_ingress_alb || var.create_alb || var.alb_target_group_arn != null
    error_message = "When enable_ingress_alb is true and create_alb is false, set alb_target_group_arn."
  }
}

check "create_alb_security_group_requires_create_alb" {
  assert {
    condition     = var.create_alb || !var.create_alb_security_group
    error_message = "create_alb_security_group can only be true when create_alb is true."
  }
}

check "alb_node_port_range_is_valid" {
  assert {
    condition = (
      var.alb_node_port_range_min >= 1
      && var.alb_node_port_range_max <= 65535
      && var.alb_node_port_range_min <= var.alb_node_port_range_max
    )
    error_message = "alb_node_port_range_min/max must be between 1 and 65535 and min <= max."
  }
}

check "alb_health_check_timeout_is_less_than_interval" {
  assert {
    condition     = var.alb_health_check_timeout < var.alb_health_check_interval
    error_message = "alb_health_check_timeout must be lower than alb_health_check_interval."
  }
}

resource "aws_security_group" "cluster" {
  count = var.create_cluster_security_group ? 1 : 0

  name        = coalesce(var.cluster_security_group_name, "${var.name}-eks-cluster-sg")
  description = "Managed by Terraform for EKS control plane."
  vpc_id      = var.vpc_id
  ingress     = []
  egress      = []

  tags = merge(local.common_tags, var.cluster_security_group_tags, {
    Name = coalesce(var.cluster_security_group_name, "${var.name}-eks-cluster-sg")
  })
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_created_node_security_group" {
  count = var.create_cluster_security_group && var.create_node_security_group ? 1 : 0

  security_group_id            = aws_security_group.cluster[0].id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.node[0].id
  description                  = "Allow worker nodes to access EKS API."
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_existing_node_security_groups" {
  for_each = var.create_cluster_security_group ? toset(var.node_security_group_ids) : toset([])

  security_group_id            = aws_security_group.cluster[0].id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = each.value
  description                  = "Allow existing worker nodes security groups to access EKS API."
}

resource "aws_vpc_security_group_ingress_rule" "cluster_public_api" {
  for_each = var.create_cluster_security_group && var.cluster_endpoint_public_access ? local.cluster_api_allowed_cidrs_by_index : {}

  security_group_id = aws_security_group.cluster[0].id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
  description       = "Allow public EKS API access from configured CIDRs."
}

resource "aws_vpc_security_group_egress_rule" "cluster_egress" {
  count = var.create_cluster_security_group ? 1 : 0

  security_group_id = aws_security_group.cluster[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow outbound traffic from EKS control plane ENIs."
}

resource "aws_security_group" "node" {
  count = var.create_node_security_group ? 1 : 0

  name        = coalesce(var.node_security_group_name, "${var.name}-eks-node-sg")
  description = "Managed by Terraform for EKS worker nodes."
  vpc_id      = var.vpc_id
  ingress     = []
  egress      = []

  tags = merge(local.common_tags, var.node_security_group_tags, {
    Name = coalesce(var.node_security_group_name, "${var.name}-eks-node-sg")
  })
}

resource "aws_vpc_security_group_ingress_rule" "node_self" {
  count = var.create_node_security_group ? 1 : 0

  security_group_id            = aws_security_group.node[0].id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.node[0].id
  description                  = "Allow node-to-node communication."
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cluster" {
  count = var.create_node_security_group ? 1 : 0

  security_group_id            = aws_security_group.node[0].id
  ip_protocol                  = "tcp"
  from_port                    = 1025
  to_port                      = 65535
  referenced_security_group_id = local.resolved_cluster_security_group_id
  description                  = "Allow EKS control plane to reach kubelet and pods."
}

resource "aws_vpc_security_group_egress_rule" "node_egress" {
  count = var.create_node_security_group ? 1 : 0

  security_group_id = aws_security_group.node[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow outbound traffic from EKS worker nodes."
}

resource "aws_security_group" "alb" {
  count = var.enable_ingress_alb && var.create_alb && var.create_alb_security_group ? 1 : 0

  name        = coalesce(var.alb_security_group_name, "${var.name}-eks-alb-sg")
  description = "Managed by Terraform for EKS ingress ALB."
  vpc_id      = var.vpc_id
  ingress     = []
  egress      = []

  tags = merge(local.common_tags, var.alb_security_group_tags, {
    Name = coalesce(var.alb_security_group_name, "${var.name}-eks-alb-sg")
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_ipv4" {
  for_each = var.enable_ingress_alb && var.create_alb && var.create_alb_security_group ? local.alb_ingress_cidrs_by_index : {}

  security_group_id = aws_security_group.alb[0].id
  ip_protocol       = "tcp"
  from_port         = var.alb_listener_port
  to_port           = var.alb_listener_port
  cidr_ipv4         = each.value
  description       = "Allow inbound traffic to EKS ingress ALB listener."
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_ipv4" {
  count = var.enable_ingress_alb && var.create_alb && var.create_alb_security_group ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic from EKS ingress ALB."
}

resource "aws_vpc_security_group_ingress_rule" "node_from_created_alb_security_group" {
  count = var.create_node_security_group && var.enable_ingress_alb && var.create_alb && var.create_alb_security_group ? 1 : 0

  security_group_id            = aws_security_group.node[0].id
  ip_protocol                  = "tcp"
  from_port                    = var.alb_node_port_range_min
  to_port                      = var.alb_node_port_range_max
  referenced_security_group_id = aws_security_group.alb[0].id
  description                  = "Allow ALB traffic to Kubernetes NodePort range."
}

resource "aws_vpc_security_group_ingress_rule" "node_from_existing_alb_security_groups" {
  for_each = var.create_node_security_group && var.enable_ingress_alb ? toset(var.create_alb && var.create_alb_security_group ? [] : var.alb_security_group_ids) : toset([])

  security_group_id            = aws_security_group.node[0].id
  ip_protocol                  = "tcp"
  from_port                    = var.alb_node_port_range_min
  to_port                      = var.alb_node_port_range_max
  referenced_security_group_id = each.value
  description                  = "Allow existing ALB security groups to reach Kubernetes NodePort range."
}

resource "aws_cloudwatch_log_group" "cluster" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = local.discovered_log_group_name
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(local.common_tags, {
    Name = local.discovered_log_group_name
  })
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = local.resolved_cluster_role_arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    security_group_ids      = local.resolved_cluster_security_group_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  tags = merge(local.common_tags, var.cluster_tags, {
    Name = local.cluster_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_default,
    aws_iam_role_policy_attachment.cluster_additional,
    aws_cloudwatch_log_group.cluster,
    aws_vpc_security_group_ingress_rule.cluster_from_created_node_security_group,
    aws_vpc_security_group_ingress_rule.cluster_from_existing_node_security_groups,
    aws_vpc_security_group_ingress_rule.cluster_public_api,
    aws_vpc_security_group_egress_rule.cluster_egress
  ]
}

data "tls_certificate" "cluster_oidc" {
  count = var.create_oidc_provider && var.oidc_thumbprint_list == null ? 1 : 0

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  client_id_list  = var.oidc_client_id_list
  thumbprint_list = local.resolved_oidc_thumbprint_list
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-oidc-provider"
  })
}

resource "aws_eks_node_group" "this" {
  for_each = var.managed_node_groups

  cluster_name         = aws_eks_cluster.this.name
  node_group_name      = each.key
  node_role_arn        = local.resolved_node_role_arn
  subnet_ids           = try(each.value.subnet_ids, null) == null || length(try(each.value.subnet_ids, [])) == 0 ? var.node_subnet_ids : each.value.subnet_ids
  ami_type             = try(each.value.ami_type, null)
  capacity_type        = upper(try(each.value.capacity_type, "ON_DEMAND"))
  disk_size            = try(each.value.disk_size, 20)
  instance_types       = try(each.value.instance_types, ["t3.medium"])
  version              = try(each.value.version, null)
  release_version      = try(each.value.release_version, null)
  force_update_version = try(each.value.force_update_version, false)

  scaling_config {
    desired_size = try(each.value.desired_size, 2)
    min_size     = try(each.value.min_size, 1)
    max_size     = try(each.value.max_size, 3)
  }

  update_config {
    max_unavailable = try(each.value.max_unavailable, 1)
  }

  labels = merge(var.node_group_labels, try(each.value.labels, {}))

  dynamic "taint" {
    for_each = try(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = upper(taint.value.effect)
    }
  }

  tags = merge(local.common_tags, var.node_group_tags, try(each.value.tags, {}), {
    Name = "${local.cluster_name}-${each.key}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_additional,
    aws_vpc_security_group_ingress_rule.node_self,
    aws_vpc_security_group_ingress_rule.node_from_cluster,
    aws_vpc_security_group_ingress_rule.node_from_created_alb_security_group,
    aws_vpc_security_group_ingress_rule.node_from_existing_alb_security_groups,
    aws_vpc_security_group_egress_rule.node_egress
  ]
}

module "alb" {
  count = var.enable_ingress_alb && var.create_alb ? 1 : 0

  source = "../alb"

  name                             = coalesce(var.alb_name, "${var.name}-eks")
  target_group_name                = var.alb_target_group_name
  internal                         = var.alb_internal
  subnet_ids                       = var.alb_subnet_ids
  security_group_ids               = local.resolved_alb_security_group_ids
  enable_deletion_protection       = var.alb_enable_deletion_protection
  idle_timeout                     = var.alb_idle_timeout
  create_target_group              = true
  vpc_id                           = var.vpc_id
  target_group_port                = var.alb_target_group_port
  target_group_protocol            = var.alb_target_group_protocol
  target_type                      = var.alb_target_type
  protocol_version                 = var.alb_protocol_version
  deregistration_delay             = var.alb_deregistration_delay
  stickiness_enabled               = var.alb_stickiness_enabled
  stickiness_cookie_duration       = var.alb_stickiness_cookie_duration
  health_check_enabled             = true
  health_check_path                = var.alb_health_check_path
  health_check_matcher             = var.alb_health_check_matcher
  health_check_interval            = var.alb_health_check_interval
  health_check_timeout             = var.alb_health_check_timeout
  health_check_healthy_threshold   = var.alb_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.alb_health_check_unhealthy_threshold
  listener_port                    = var.alb_listener_port
  listener_protocol                = var.alb_listener_protocol
  listener_ssl_policy              = var.alb_listener_ssl_policy
  listener_certificate_arn         = var.alb_listener_certificate_arn
  listener_default_action_type     = "forward"
  target_attachments               = var.alb_target_attachments

  create_acm_certificate        = var.alb_create_acm_certificate
  acm_domain_name               = var.alb_acm_domain_name
  acm_subject_alternative_names = var.alb_acm_subject_alternative_names
  acm_validation_method         = var.alb_acm_validation_method
  acm_hosted_zone_id            = var.alb_acm_hosted_zone_id
  acm_create_route53_records    = var.alb_acm_create_route53_records
  acm_validation_record_ttl     = var.alb_acm_validation_record_ttl
  acm_wait_for_validation       = var.alb_acm_wait_for_validation
  acm_certificate_tags          = var.alb_acm_certificate_tags

  tags               = local.common_tags
  load_balancer_tags = var.alb_tags
  target_group_tags  = var.alb_target_group_tags
}
