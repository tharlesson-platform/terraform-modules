variable "name" {
  description = "Base name used for ALB resources."
  type        = string
}

variable "load_balancer_name" {
  description = "Optional explicit name for the ALB."
  type        = string
  default     = null
}

variable "target_group_name" {
  description = "Optional explicit name for the target group."
  type        = string
  default     = null
}

variable "internal" {
  description = "Whether the ALB is internal."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs attached to the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the ALB."
  type        = list(string)
  default     = []
}

variable "ip_address_type" {
  description = "IP address type for the ALB (ipv4 or dualstack)."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be ipv4 or dualstack."
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 on the ALB."
  type        = bool
  default     = true
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid headers on requests."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds for connections."
  type        = number
  default     = 60

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "idle_timeout must be between 1 and 4000."
  }
}

variable "access_logs" {
  description = "Optional ALB access logs configuration."
  type = object({
    bucket  = string
    prefix  = optional(string)
    enabled = optional(bool, true)
  })
  default = null
}

variable "create_target_group" {
  description = "Create a target group in this module."
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "Existing target group ARN used when create_target_group is false."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID used when create_target_group is true."
  type        = string
  default     = null
}

variable "target_group_port" {
  description = "Port used by the created target group."
  type        = number
  default     = 80

  validation {
    condition     = var.target_group_port >= 1 && var.target_group_port <= 65535
    error_message = "target_group_port must be between 1 and 65535."
  }
}

variable "target_group_protocol" {
  description = "Protocol used by the created target group."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.target_group_protocol))
    error_message = "target_group_protocol must be HTTP or HTTPS."
  }
}

variable "target_type" {
  description = "Target type for the created target group."
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "target_type must be instance or ip."
  }
}

variable "protocol_version" {
  description = "Optional protocol version for the created target group."
  type        = string
  default     = null

  validation {
    condition = var.protocol_version == null ? true : contains([
      "HTTP1",
      "HTTP2",
      "GRPC"
    ], upper(var.protocol_version))
    error_message = "protocol_version must be HTTP1, HTTP2, GRPC, or null."
  }
}

variable "deregistration_delay" {
  description = "Deregistration delay in seconds for target group."
  type        = number
  default     = 300

  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "deregistration_delay must be between 0 and 3600."
  }
}

variable "slow_start" {
  description = "Slow start in seconds for target group."
  type        = number
  default     = 0

  validation {
    condition     = var.slow_start >= 0 && var.slow_start <= 900
    error_message = "slow_start must be between 0 and 900."
  }
}

variable "stickiness_enabled" {
  description = "Enable target group stickiness."
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Stickiness type for target group."
  type        = string
  default     = "lb_cookie"

  validation {
    condition     = contains(["lb_cookie"], var.stickiness_type)
    error_message = "stickiness_type must be lb_cookie."
  }
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration in seconds when stickiness is enabled."
  type        = number
  default     = 86400

  validation {
    condition     = var.stickiness_cookie_duration >= 1 && var.stickiness_cookie_duration <= 604800
    error_message = "stickiness_cookie_duration must be between 1 and 604800."
  }
}

variable "health_check_enabled" {
  description = "Enable health check on target group."
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path used by target group health check."
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP code matcher used by health check."
  type        = string
  default     = "200-399"
}

variable "health_check_port" {
  description = "Port used by health check."
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Optional protocol used by health check."
  type        = string
  default     = null

  validation {
    condition     = var.health_check_protocol == null ? true : contains(["HTTP", "HTTPS"], upper(var.health_check_protocol))
    error_message = "health_check_protocol must be HTTP, HTTPS, or null."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds."
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "health_check_timeout must be between 2 and 120."
  }
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for target group health check."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "health_check_healthy_threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for target group health check."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "health_check_unhealthy_threshold must be between 2 and 10."
  }
}

variable "listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 80

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "listener_port must be between 1 and 65535."
  }
}

variable "listener_protocol" {
  description = "ALB listener protocol."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.listener_protocol))
    error_message = "listener_protocol must be HTTP or HTTPS."
  }
}

variable "listener_ssl_policy" {
  description = "Optional SSL policy for HTTPS listener."
  type        = string
  default     = null
}

variable "listener_certificate_arn" {
  description = "ACM certificate ARN used when listener_protocol is HTTPS."
  type        = string
  default     = null
}

variable "create_acm_certificate" {
  description = "Create ACM certificate in this module and attach it to HTTPS listener."
  type        = bool
  default     = false
}

variable "acm_domain_name" {
  description = "Primary domain name for ACM certificate created by this module."
  type        = string
  default     = null
}

variable "acm_subject_alternative_names" {
  description = "Optional SAN entries for ACM certificate."
  type        = list(string)
  default     = []
}

variable "acm_validation_method" {
  description = "Validation method used by ACM certificate (DNS or EMAIL)."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], upper(var.acm_validation_method))
    error_message = "acm_validation_method must be DNS or EMAIL."
  }
}

variable "acm_hosted_zone_id" {
  description = "Route53 hosted zone ID used to create DNS validation records."
  type        = string
  default     = null
}

variable "acm_create_route53_records" {
  description = "Whether to create Route53 DNS validation records for ACM."
  type        = bool
  default     = true
}

variable "acm_validation_record_ttl" {
  description = "TTL in seconds for ACM DNS validation records."
  type        = number
  default     = 60

  validation {
    condition     = var.acm_validation_record_ttl >= 1 && var.acm_validation_record_ttl <= 172800
    error_message = "acm_validation_record_ttl must be between 1 and 172800."
  }
}

variable "acm_wait_for_validation" {
  description = "Whether Terraform should wait for ACM certificate validation."
  type        = bool
  default     = true
}

variable "acm_certificate_tags" {
  description = "Additional tags applied only to ACM certificate."
  type        = map(string)
  default     = {}
}

variable "listener_default_action_type" {
  description = "Default listener action type (forward, redirect, fixed-response)."
  type        = string
  default     = "forward"

  validation {
    condition     = contains(["forward", "redirect", "fixed-response"], var.listener_default_action_type)
    error_message = "listener_default_action_type must be forward, redirect, or fixed-response."
  }
}

variable "redirect_host" {
  description = "Host value for redirect action."
  type        = string
  default     = "#{host}"
}

variable "redirect_path" {
  description = "Path value for redirect action."
  type        = string
  default     = "/#{path}"
}

variable "redirect_port" {
  description = "Port value for redirect action."
  type        = string
  default     = "443"
}

variable "redirect_protocol" {
  description = "Protocol value for redirect action."
  type        = string
  default     = "HTTPS"
}

variable "redirect_query" {
  description = "Query value for redirect action."
  type        = string
  default     = "#{query}"
}

variable "redirect_status_code" {
  description = "Status code for redirect action."
  type        = string
  default     = "HTTP_301"

  validation {
    condition     = contains(["HTTP_301", "HTTP_302"], var.redirect_status_code)
    error_message = "redirect_status_code must be HTTP_301 or HTTP_302."
  }
}

variable "fixed_response_content_type" {
  description = "Content type for fixed-response action."
  type        = string
  default     = "text/plain"

  validation {
    condition = contains([
      "text/plain",
      "text/css",
      "text/html",
      "application/javascript",
      "application/json"
    ], var.fixed_response_content_type)
    error_message = "fixed_response_content_type is invalid."
  }
}

variable "fixed_response_message_body" {
  description = "Message body for fixed-response action."
  type        = string
  default     = "OK"
}

variable "fixed_response_status_code" {
  description = "Status code for fixed-response action."
  type        = string
  default     = "200"
}

variable "target_attachments" {
  description = "Targets attached to resolved target group."
  type = list(object({
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "load_balancer_tags" {
  description = "Additional tags for ALB resource."
  type        = map(string)
  default     = {}
}

variable "target_group_tags" {
  description = "Additional tags for target group resource."
  type        = map(string)
  default     = {}
}
