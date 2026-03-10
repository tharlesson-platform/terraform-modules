variable "name" {
  description = "Base name used for EKS resources."
  type        = string
}

variable "cluster_name" {
  description = "Optional explicit EKS cluster name."
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Optional Kubernetes version for EKS cluster (for example 1.30)."
  type        = string
  default     = null
}

variable "create_cluster_role" {
  description = "Create IAM role for EKS control plane."
  type        = bool
  default     = true
}

variable "cluster_role_arn" {
  description = "Existing IAM role ARN for EKS control plane when create_cluster_role is false."
  type        = string
  default     = null
}

variable "cluster_role_name" {
  description = "Optional explicit IAM role name for EKS control plane."
  type        = string
  default     = null
}

variable "cluster_role_permissions_boundary" {
  description = "Optional permissions boundary for EKS control plane role."
  type        = string
  default     = null
}

variable "cluster_role_policy_arns" {
  description = "Additional IAM managed policy ARNs attached to EKS control plane role."
  type        = list(string)
  default     = []
}

variable "create_node_role" {
  description = "Create IAM role for EKS managed node groups."
  type        = bool
  default     = true
}

variable "node_role_arn" {
  description = "Existing IAM role ARN for EKS node groups when create_node_role is false."
  type        = string
  default     = null
}

variable "node_role_name" {
  description = "Optional explicit IAM role name for EKS node groups."
  type        = string
  default     = null
}

variable "node_role_permissions_boundary" {
  description = "Optional permissions boundary for EKS node role."
  type        = string
  default     = null
}

variable "node_role_policy_arns" {
  description = "Additional IAM managed policy ARNs attached to EKS node role."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID used by EKS and ALB security groups."
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs attached to EKS control plane ENIs."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Default subnet IDs used by managed node groups when group subnet_ids are not provided."
  type        = list(string)
  default     = []
}

variable "create_cluster_security_group" {
  description = "Create dedicated security group for EKS control plane."
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID used by EKS control plane when create_cluster_security_group is false."
  type        = string
  default     = null
}

variable "cluster_security_group_name" {
  description = "Optional explicit name for created EKS control plane security group."
  type        = string
  default     = null
}

variable "cluster_security_group_additional_ids" {
  description = "Additional security group IDs attached to EKS control plane ENIs."
  type        = list(string)
  default     = []
}

variable "create_node_security_group" {
  description = "Create dedicated security group for EKS worker nodes."
  type        = bool
  default     = true
}

variable "node_security_group_name" {
  description = "Optional explicit name for created EKS worker nodes security group."
  type        = string
  default     = null
}

variable "node_security_group_ids" {
  description = "Existing security group IDs attached to node groups when create_node_security_group is false."
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Enable private endpoint for EKS control plane API server."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public endpoint for EKS control plane API server."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach public EKS control plane endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_cloudwatch_log_group" {
  description = "Create CloudWatch log group for EKS control plane logs."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Optional explicit log group name for EKS control plane logs."
  type        = string
  default     = null
}

variable "log_group_retention_in_days" {
  description = "Retention period in days for EKS control plane log group."
  type        = number
  default     = 30
}

variable "log_group_kms_key_id" {
  description = "Optional KMS key ID used to encrypt EKS control plane logs."
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types enabled on cluster."
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "enabled_cluster_log_types accepts only api, audit, authenticator, controllerManager and scheduler."
  }
}

variable "create_oidc_provider" {
  description = "Create IAM OIDC provider for EKS cluster identity."
  type        = bool
  default     = true
}

variable "oidc_client_id_list" {
  description = "Client IDs used by IAM OIDC provider."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "oidc_thumbprint_list" {
  description = "Optional thumbprint list for IAM OIDC provider. When null, TLS certificate fingerprint is discovered automatically."
  type        = list(string)
  default     = null
}

variable "managed_node_groups" {
  description = "Map of EKS managed node groups."
  type = map(object({
    subnet_ids           = optional(list(string))
    instance_types       = optional(list(string), ["t3.medium"])
    capacity_type        = optional(string, "ON_DEMAND")
    ami_type             = optional(string)
    disk_size            = optional(number, 20)
    desired_size         = optional(number, 2)
    min_size             = optional(number, 1)
    max_size             = optional(number, 3)
    max_unavailable      = optional(number, 1)
    labels               = optional(map(string), {})
    tags                 = optional(map(string), {})
    version              = optional(string)
    release_version      = optional(string)
    force_update_version = optional(bool, false)
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
  default = {
    default = {}
  }

  validation {
    condition = alltrue([
      for node_group in values(var.managed_node_groups) :
      contains(["ON_DEMAND", "SPOT"], upper(node_group.capacity_type))
    ])
    error_message = "managed_node_groups capacity_type must be ON_DEMAND or SPOT."
  }

  validation {
    condition = alltrue(flatten([
      for node_group in values(var.managed_node_groups) : [
        for taint in node_group.taints :
        contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], upper(taint.effect))
      ]
    ]))
    error_message = "managed_node_groups taints.effect must be NO_SCHEDULE, NO_EXECUTE or PREFER_NO_SCHEDULE."
  }
}

variable "node_group_labels" {
  description = "Default labels applied to all managed node groups."
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "Default tags applied to all managed node groups."
  type        = map(string)
  default     = {}
}

variable "enable_ingress_alb" {
  description = "Enable ALB composition for EKS ingress workloads."
  type        = bool
  default     = true
}

variable "create_alb" {
  description = "Create ALB in this module for EKS ingress."
  type        = bool
  default     = true
}

variable "alb_target_group_arn" {
  description = "Existing ALB target group ARN used when create_alb is false."
  type        = string
  default     = null
}

variable "alb_name" {
  description = "Optional explicit ALB name."
  type        = string
  default     = null
}

variable "alb_internal" {
  description = "Whether EKS ingress ALB is internal."
  type        = bool
  default     = false
}

variable "alb_subnet_ids" {
  description = "Subnet IDs used by ALB."
  type        = list(string)
  default     = []
}

variable "create_alb_security_group" {
  description = "Create ALB security group."
  type        = bool
  default     = true
}

variable "alb_security_group_name" {
  description = "Optional explicit ALB security group name."
  type        = string
  default     = null
}

variable "alb_security_group_ids" {
  description = "Existing security group IDs used by ALB when create_alb_security_group is false."
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 443

  validation {
    condition     = var.alb_listener_port >= 1 && var.alb_listener_port <= 65535
    error_message = "alb_listener_port must be between 1 and 65535."
  }
}

variable "alb_listener_protocol" {
  description = "ALB listener protocol."
  type        = string
  default     = "HTTPS"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.alb_listener_protocol))
    error_message = "alb_listener_protocol must be HTTP or HTTPS."
  }
}

variable "alb_listener_ssl_policy" {
  description = "Optional SSL policy for HTTPS listener."
  type        = string
  default     = null
}

variable "alb_listener_certificate_arn" {
  description = "Existing ACM certificate ARN for HTTPS listener."
  type        = string
  default     = null
}

variable "alb_target_group_name" {
  description = "Optional explicit ALB target group name."
  type        = string
  default     = null
}

variable "alb_target_group_port" {
  description = "ALB target group port."
  type        = number
  default     = 80

  validation {
    condition     = var.alb_target_group_port >= 1 && var.alb_target_group_port <= 65535
    error_message = "alb_target_group_port must be between 1 and 65535."
  }
}

variable "alb_target_group_protocol" {
  description = "ALB target group protocol."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.alb_target_group_protocol))
    error_message = "alb_target_group_protocol must be HTTP or HTTPS."
  }
}

variable "alb_target_type" {
  description = "ALB target group target type."
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip"], var.alb_target_type)
    error_message = "alb_target_type must be instance or ip."
  }
}

variable "alb_protocol_version" {
  description = "Optional protocol version for ALB target group."
  type        = string
  default     = null
}

variable "alb_health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/healthz"
}

variable "alb_health_check_matcher" {
  description = "ALB target group health check matcher."
  type        = string
  default     = "200-399"
}

variable "alb_health_check_interval" {
  description = "ALB target group health check interval in seconds."
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "ALB target group health check timeout in seconds."
  type        = number
  default     = 5
}

variable "alb_health_check_healthy_threshold" {
  description = "ALB target group healthy threshold."
  type        = number
  default     = 3
}

variable "alb_health_check_unhealthy_threshold" {
  description = "ALB target group unhealthy threshold."
  type        = number
  default     = 3
}

variable "alb_deregistration_delay" {
  description = "ALB target group deregistration delay in seconds."
  type        = number
  default     = 300
}

variable "alb_stickiness_enabled" {
  description = "Enable ALB target group stickiness."
  type        = bool
  default     = false
}

variable "alb_stickiness_cookie_duration" {
  description = "ALB target group stickiness cookie duration in seconds."
  type        = number
  default     = 86400
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB."
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "alb_node_port_range_min" {
  description = "NodePort range start exposed from worker nodes to ALB security group."
  type        = number
  default     = 30000
}

variable "alb_node_port_range_max" {
  description = "NodePort range end exposed from worker nodes to ALB security group."
  type        = number
  default     = 32767
}

variable "alb_target_attachments" {
  description = "Optional static target attachments in ALB target group."
  type = list(object({
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = []
}

variable "alb_create_acm_certificate" {
  description = "Create ACM certificate through ALB module."
  type        = bool
  default     = false
}

variable "alb_acm_domain_name" {
  description = "Domain name for ACM certificate."
  type        = string
  default     = null
}

variable "alb_acm_subject_alternative_names" {
  description = "Optional ACM SAN entries."
  type        = list(string)
  default     = []
}

variable "alb_acm_validation_method" {
  description = "ACM validation method."
  type        = string
  default     = "DNS"
}

variable "alb_acm_hosted_zone_id" {
  description = "Route53 hosted zone ID for ACM DNS validation."
  type        = string
  default     = null
}

variable "alb_acm_create_route53_records" {
  description = "Create Route53 records for ACM validation."
  type        = bool
  default     = true
}

variable "alb_acm_validation_record_ttl" {
  description = "TTL in seconds for ACM DNS validation records."
  type        = number
  default     = 60
}

variable "alb_acm_wait_for_validation" {
  description = "Wait for ACM certificate validation."
  type        = bool
  default     = true
}

variable "alb_acm_certificate_tags" {
  description = "Additional tags applied only to ACM certificate created by ALB module."
  type        = map(string)
  default     = {}
}

variable "alb_tags" {
  description = "Additional tags for ALB resource."
  type        = map(string)
  default     = {}
}

variable "alb_target_group_tags" {
  description = "Additional tags for ALB target group resource."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags applied to EKS cluster resource."
  type        = map(string)
  default     = {}
}

variable "cluster_role_tags" {
  description = "Additional tags applied to EKS control plane role."
  type        = map(string)
  default     = {}
}

variable "node_role_tags" {
  description = "Additional tags applied to EKS node role."
  type        = map(string)
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "Additional tags applied to EKS control plane security group."
  type        = map(string)
  default     = {}
}

variable "node_security_group_tags" {
  description = "Additional tags applied to EKS worker nodes security group."
  type        = map(string)
  default     = {}
}

variable "alb_security_group_tags" {
  description = "Additional tags applied to ALB security group."
  type        = map(string)
  default     = {}
}
