locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "eks"
  })
}

module "eks" {
  source = "../../../modules/eks"

  name            = "${var.client}-${var.environment}-${var.workload_name}"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_cluster_role               = var.create_cluster_role
  cluster_role_arn                  = var.cluster_role_arn
  cluster_role_name                 = var.cluster_role_name
  cluster_role_permissions_boundary = var.cluster_role_permissions_boundary
  cluster_role_policy_arns          = var.cluster_role_policy_arns

  create_node_role               = var.create_node_role
  node_role_arn                  = var.node_role_arn
  node_role_name                 = var.node_role_name
  node_role_permissions_boundary = var.node_role_permissions_boundary
  node_role_policy_arns          = var.node_role_policy_arns

  vpc_id                                = var.vpc_id
  cluster_subnet_ids                    = var.cluster_subnet_ids
  node_subnet_ids                       = var.node_subnet_ids
  create_cluster_security_group         = var.create_cluster_security_group
  cluster_security_group_id             = var.cluster_security_group_id
  cluster_security_group_name           = var.cluster_security_group_name
  cluster_security_group_additional_ids = var.cluster_security_group_additional_ids
  create_node_security_group            = var.create_node_security_group
  node_security_group_name              = var.node_security_group_name
  node_security_group_ids               = var.node_security_group_ids

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  log_group_name              = var.log_group_name
  log_group_retention_in_days = var.log_group_retention_in_days
  log_group_kms_key_id        = var.log_group_kms_key_id
  enabled_cluster_log_types   = var.enabled_cluster_log_types

  create_oidc_provider = var.create_oidc_provider
  oidc_client_id_list  = var.oidc_client_id_list
  oidc_thumbprint_list = var.oidc_thumbprint_list

  managed_node_groups = var.managed_node_groups
  node_group_labels   = var.node_group_labels
  node_group_tags     = var.node_group_tags

  enable_ingress_alb                   = var.enable_ingress_alb
  create_alb                           = var.create_alb
  alb_target_group_arn                 = var.alb_target_group_arn
  alb_name                             = var.alb_name
  alb_internal                         = var.alb_internal
  alb_subnet_ids                       = var.alb_subnet_ids
  create_alb_security_group            = var.create_alb_security_group
  alb_security_group_name              = var.alb_security_group_name
  alb_security_group_ids               = var.alb_security_group_ids
  alb_ingress_cidr_blocks              = var.alb_ingress_cidr_blocks
  alb_listener_port                    = var.alb_listener_port
  alb_listener_protocol                = var.alb_listener_protocol
  alb_listener_ssl_policy              = var.alb_listener_ssl_policy
  alb_listener_certificate_arn         = var.alb_listener_certificate_arn
  alb_target_group_name                = var.alb_target_group_name
  alb_target_group_port                = var.alb_target_group_port
  alb_target_group_protocol            = var.alb_target_group_protocol
  alb_target_type                      = var.alb_target_type
  alb_protocol_version                 = var.alb_protocol_version
  alb_health_check_path                = var.alb_health_check_path
  alb_health_check_matcher             = var.alb_health_check_matcher
  alb_health_check_interval            = var.alb_health_check_interval
  alb_health_check_timeout             = var.alb_health_check_timeout
  alb_health_check_healthy_threshold   = var.alb_health_check_healthy_threshold
  alb_health_check_unhealthy_threshold = var.alb_health_check_unhealthy_threshold
  alb_deregistration_delay             = var.alb_deregistration_delay
  alb_stickiness_enabled               = var.alb_stickiness_enabled
  alb_stickiness_cookie_duration       = var.alb_stickiness_cookie_duration
  alb_enable_deletion_protection       = var.alb_enable_deletion_protection
  alb_idle_timeout                     = var.alb_idle_timeout
  alb_node_port_range_min              = var.alb_node_port_range_min
  alb_node_port_range_max              = var.alb_node_port_range_max
  alb_target_attachments               = var.alb_target_attachments

  alb_create_acm_certificate        = var.alb_create_acm_certificate
  alb_acm_domain_name               = var.alb_acm_domain_name
  alb_acm_subject_alternative_names = var.alb_acm_subject_alternative_names
  alb_acm_validation_method         = var.alb_acm_validation_method
  alb_acm_hosted_zone_id            = var.alb_acm_hosted_zone_id
  alb_acm_create_route53_records    = var.alb_acm_create_route53_records
  alb_acm_validation_record_ttl     = var.alb_acm_validation_record_ttl
  alb_acm_wait_for_validation       = var.alb_acm_wait_for_validation
  alb_acm_certificate_tags          = var.alb_acm_certificate_tags

  tags                        = local.common_tags
  cluster_tags                = var.cluster_tags
  cluster_role_tags           = var.cluster_role_tags
  node_role_tags              = var.node_role_tags
  cluster_security_group_tags = var.cluster_security_group_tags
  node_security_group_tags    = var.node_security_group_tags
  alb_security_group_tags     = var.alb_security_group_tags
  alb_tags                    = var.alb_tags
  alb_target_group_tags       = var.alb_target_group_tags
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  value = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_node_group_arns" {
  value = module.eks.node_group_arns
}

output "eks_control_plane_security_group_id" {
  value = module.eks.control_plane_security_group_id
}

output "eks_node_security_group_ids" {
  value = module.eks.node_security_group_ids
}

output "alb_dns_name" {
  value = module.eks.ingress_alb_load_balancer_dns_name
}

output "alb_target_group_arn" {
  value = module.eks.ingress_target_group_arn
}

output "alb_acm_certificate_arn" {
  value = module.eks.ingress_alb_acm_certificate_arn
}
