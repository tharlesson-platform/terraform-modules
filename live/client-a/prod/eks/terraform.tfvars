region      = "us-east-1"
aws_profile = "client-a-prod"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-eks-client-a-prod"

client        = "client-a"
environment   = "prod"
workload_name = "platform"

cluster_name    = null
cluster_version = null

create_cluster_role               = true
cluster_role_arn                  = null
cluster_role_name                 = null
cluster_role_permissions_boundary = null
cluster_role_policy_arns          = []

create_node_role               = true
node_role_arn                  = null
node_role_name                 = null
node_role_permissions_boundary = null
node_role_policy_arns          = []

# Output do stack vpc
vpc_id = "vpc-0123456789abcdef0"
cluster_subnet_ids = [
  "subnet-0privatea",
  "subnet-0privateb"
]
node_subnet_ids = [
  "subnet-0privatea",
  "subnet-0privateb"
]

create_cluster_security_group         = true
cluster_security_group_id             = null
cluster_security_group_name           = null
cluster_security_group_additional_ids = []
create_node_security_group            = true
node_security_group_name              = null
node_security_group_ids               = []

cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

create_cloudwatch_log_group = true
log_group_name              = null
log_group_retention_in_days = 30
log_group_kms_key_id        = null
enabled_cluster_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]

create_oidc_provider = true
oidc_client_id_list  = ["sts.amazonaws.com"]
oidc_thumbprint_list = null

managed_node_groups = {
  default = {
    instance_types  = ["t3.medium"]
    capacity_type   = "ON_DEMAND"
    disk_size       = 30
    desired_size    = 2
    min_size        = 1
    max_size        = 3
    max_unavailable = 1
    labels = {
      role = "general"
    }
    taints = []
  }
}

node_group_labels = {
  workload = "platform"
}
node_group_tags = {}

enable_ingress_alb   = true
create_alb           = true
alb_target_group_arn = null
alb_name             = null
alb_internal         = false
alb_subnet_ids = [
  "subnet-0publica",
  "subnet-0publicb"
]
create_alb_security_group = true
alb_security_group_name   = null
alb_security_group_ids    = []
alb_ingress_cidr_blocks = [
  "0.0.0.0/0"
]
alb_listener_port                    = 443
alb_listener_protocol                = "HTTPS"
alb_listener_ssl_policy              = null
alb_listener_certificate_arn         = null
alb_target_group_name                = null
alb_target_group_port                = 80
alb_target_group_protocol            = "HTTP"
alb_target_type                      = "instance"
alb_protocol_version                 = null
alb_health_check_path                = "/healthz"
alb_health_check_matcher             = "200-399"
alb_health_check_interval            = 30
alb_health_check_timeout             = 5
alb_health_check_healthy_threshold   = 3
alb_health_check_unhealthy_threshold = 3
alb_deregistration_delay             = 300
alb_stickiness_enabled               = false
alb_stickiness_cookie_duration       = 86400
alb_enable_deletion_protection       = false
alb_idle_timeout                     = 60
alb_node_port_range_min              = 30000
alb_node_port_range_max              = 32767
alb_target_attachments               = []

alb_create_acm_certificate        = true
alb_acm_domain_name               = "apps.client-a.example.com"
alb_acm_subject_alternative_names = []
alb_acm_validation_method         = "DNS"
alb_acm_hosted_zone_id            = "Z1234567890EXAMPLE"
alb_acm_create_route53_records    = true
alb_acm_validation_record_ttl     = 60
alb_acm_wait_for_validation       = true
alb_acm_certificate_tags          = {}

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}

cluster_tags                = {}
cluster_role_tags           = {}
node_role_tags              = {}
cluster_security_group_tags = {}
node_security_group_tags    = {}
alb_security_group_tags     = {}
alb_tags                    = {}
alb_target_group_tags       = {}
