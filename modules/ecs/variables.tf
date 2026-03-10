variable "name" {
  description = "Base name used for ECS resources."
  type        = string
}

variable "cluster_name" {
  description = "Optional explicit ECS cluster name."
  type        = string
  default     = null
}

variable "create_cluster" {
  description = "Create ECS cluster in this module."
  type        = bool
  default     = true
}

variable "existing_cluster_arn" {
  description = "Existing ECS cluster ARN used when create_cluster is false."
  type        = string
  default     = null
}

variable "service_name" {
  description = "Optional explicit ECS service name."
  type        = string
  default     = null
}

variable "task_definition_family" {
  description = "Optional explicit ECS task definition family."
  type        = string
  default     = null
}

variable "enable_container_insights" {
  description = "Enable ECS container insights at cluster level."
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image used by primary ECS container."
  type        = string
}

variable "container_name" {
  description = "Optional explicit container name. Defaults to module name."
  type        = string
  default     = null
}

variable "container_port" {
  description = "Container port exposed by primary container."
  type        = number
  default     = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "container_protocol" {
  description = "Container transport protocol."
  type        = string
  default     = "tcp"

  validation {
    condition     = contains(["tcp", "udp"], lower(var.container_protocol))
    error_message = "container_protocol must be tcp or udp."
  }
}

variable "container_command" {
  description = "Optional command array for primary container."
  type        = list(string)
  default     = null
}

variable "container_entrypoint" {
  description = "Optional entrypoint array for primary container."
  type        = list(string)
  default     = null
}

variable "container_environment" {
  description = "Environment variables injected in primary container."
  type        = map(string)
  default     = {}
}

variable "container_secrets" {
  description = "Secrets injected in primary container."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

variable "container_health_check" {
  description = "Optional health check for primary container."
  type = object({
    command      = list(string)
    interval     = optional(number, 30)
    timeout      = optional(number, 5)
    retries      = optional(number, 3)
    start_period = optional(number, 0)
  })
  default = null

  validation {
    condition     = var.container_health_check == null || length(var.container_health_check.command) > 0
    error_message = "container_health_check.command must contain at least one command token."
  }
}

variable "container_readonly_root_filesystem" {
  description = "Enable read-only root filesystem for primary container."
  type        = bool
  default     = false
}

variable "container_log_stream_prefix" {
  description = "CloudWatch Logs stream prefix for primary container."
  type        = string
  default     = "ecs"
}

variable "container_start_timeout" {
  description = "Optional container start timeout in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.container_start_timeout == null || try(var.container_start_timeout >= 2 && var.container_start_timeout <= 120, false)
    error_message = "container_start_timeout must be between 2 and 120 seconds when provided."
  }
}

variable "container_stop_timeout" {
  description = "Optional container stop timeout in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.container_stop_timeout == null || try(var.container_stop_timeout >= 2 && var.container_stop_timeout <= 120, false)
    error_message = "container_stop_timeout must be between 2 and 120 seconds when provided."
  }
}

variable "task_cpu" {
  description = "Task CPU units."
  type        = number
  default     = 256

  validation {
    condition     = var.task_cpu > 0
    error_message = "task_cpu must be greater than 0."
  }
}

variable "task_memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 512

  validation {
    condition     = var.task_memory > 0
    error_message = "task_memory must be greater than 0."
  }
}

variable "network_mode" {
  description = "Task definition network mode."
  type        = string
  default     = "awsvpc"

  validation {
    condition     = contains(["awsvpc", "bridge", "host", "none"], var.network_mode)
    error_message = "network_mode must be awsvpc, bridge, host, or none."
  }
}

variable "requires_compatibilities" {
  description = "Task definition compatibilities."
  type        = list(string)
  default     = ["FARGATE"]

  validation {
    condition     = length(var.requires_compatibilities) > 0
    error_message = "requires_compatibilities must contain at least one compatibility."
  }
}

variable "runtime_cpu_architecture" {
  description = "Task runtime CPU architecture."
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], upper(var.runtime_cpu_architecture))
    error_message = "runtime_cpu_architecture must be X86_64 or ARM64."
  }
}

variable "runtime_operating_system_family" {
  description = "Task runtime operating system family."
  type        = string
  default     = "LINUX"

  validation {
    condition = contains([
      "LINUX",
      "WINDOWS_SERVER_2019_FULL",
      "WINDOWS_SERVER_2019_CORE",
      "WINDOWS_SERVER_2022_FULL",
      "WINDOWS_SERVER_2022_CORE"
    ], upper(var.runtime_operating_system_family))
    error_message = "runtime_operating_system_family is invalid."
  }
}

variable "ephemeral_storage_size" {
  description = "Optional task ephemeral storage size in GiB."
  type        = number
  default     = null

  validation {
    condition     = var.ephemeral_storage_size == null || try(var.ephemeral_storage_size >= 21 && var.ephemeral_storage_size <= 200, false)
    error_message = "ephemeral_storage_size must be between 21 and 200 when provided."
  }
}

variable "create_cloudwatch_log_group" {
  description = "Create CloudWatch log group for container logs."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Optional explicit CloudWatch log group name."
  type        = string
  default     = null
}

variable "log_group_retention_in_days" {
  description = "Log retention in days for created CloudWatch log group."
  type        = number
  default     = 30

  validation {
    condition     = var.log_group_retention_in_days >= 1
    error_message = "log_group_retention_in_days must be greater than or equal to 1."
  }
}

variable "log_group_kms_key_id" {
  description = "Optional KMS key ID used to encrypt CloudWatch logs."
  type        = string
  default     = null
}

variable "create_execution_role" {
  description = "Create IAM execution role for ECS tasks."
  type        = bool
  default     = true
}

variable "execution_role_arn" {
  description = "Existing IAM execution role ARN used when create_execution_role is false."
  type        = string
  default     = null
}

variable "execution_role_name" {
  description = "Optional explicit execution role name."
  type        = string
  default     = null
}

variable "execution_role_description" {
  description = "Description for created execution role."
  type        = string
  default     = "Managed by Terraform for ECS task execution."
}

variable "execution_role_path" {
  description = "Path for created execution role."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.execution_role_path, "/") && endswith(var.execution_role_path, "/")
    error_message = "execution_role_path must start and end with '/'."
  }
}

variable "execution_role_permissions_boundary" {
  description = "Optional permissions boundary ARN for execution role."
  type        = string
  default     = null
}

variable "execution_role_policy_arns" {
  description = "Additional managed policy ARNs attached to execution role."
  type        = list(string)
  default     = []
}

variable "create_task_role" {
  description = "Create IAM task role for ECS application permissions."
  type        = bool
  default     = true
}

variable "task_role_arn" {
  description = "Existing IAM task role ARN used when create_task_role is false."
  type        = string
  default     = null
}

variable "task_role_name" {
  description = "Optional explicit task role name."
  type        = string
  default     = null
}

variable "task_role_description" {
  description = "Description for created task role."
  type        = string
  default     = "Managed by Terraform for ECS task runtime permissions."
}

variable "task_role_path" {
  description = "Path for created task role."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.task_role_path, "/") && endswith(var.task_role_path, "/")
    error_message = "task_role_path must start and end with '/'."
  }
}

variable "task_role_permissions_boundary" {
  description = "Optional permissions boundary ARN for task role."
  type        = string
  default     = null
}

variable "task_role_policy_arns" {
  description = "Managed policy ARNs attached to created task role."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID used to create ECS and ALB security groups."
  type        = string
  default     = null
}

variable "service_subnet_ids" {
  description = "Subnet IDs used by ECS service network configuration."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks."
  type        = bool
  default     = false
}

variable "create_service_security_group" {
  description = "Create security group for ECS service ENIs."
  type        = bool
  default     = true
}

variable "service_security_group_name" {
  description = "Optional explicit ECS service security group name."
  type        = string
  default     = null
}

variable "service_security_group_ids" {
  description = "Existing security groups attached to ECS service."
  type        = list(string)
  default     = []
}

variable "service_ingress_cidr_blocks" {
  description = "Additional CIDR ranges allowed to access container port."
  type        = list(string)
  default     = []
}

variable "service_egress_cidr_blocks" {
  description = "CIDR ranges allowed for ECS service outbound traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0
    error_message = "desired_count must be greater than or equal to 0."
  }
}

variable "launch_type" {
  description = "ECS service launch type."
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "EC2", "EXTERNAL"], upper(var.launch_type))
    error_message = "launch_type must be FARGATE, EC2, or EXTERNAL."
  }
}

variable "platform_version" {
  description = "ECS service platform version for Fargate."
  type        = string
  default     = "LATEST"
}

variable "scheduling_strategy" {
  description = "ECS service scheduling strategy."
  type        = string
  default     = "REPLICA"

  validation {
    condition     = contains(["REPLICA", "DAEMON"], upper(var.scheduling_strategy))
    error_message = "scheduling_strategy must be REPLICA or DAEMON."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during ECS deployments."
  type        = number
  default     = 50

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

variable "deployment_maximum_percent" {
  description = "Maximum deployment percent during ECS deployments."
  type        = number
  default     = 200

  validation {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 200
    error_message = "deployment_maximum_percent must be between 100 and 200."
  }
}

variable "health_check_grace_period_seconds" {
  description = "Service health check grace period in seconds."
  type        = number
  default     = 60

  validation {
    condition     = var.health_check_grace_period_seconds >= 0
    error_message = "health_check_grace_period_seconds must be greater than or equal to 0."
  }
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service."
  type        = bool
  default     = true
}

variable "enable_ecs_managed_tags" {
  description = "Enable ECS managed tags on tasks."
  type        = bool
  default     = true
}

variable "propagate_tags" {
  description = "Tag propagation strategy for ECS service."
  type        = string
  default     = "SERVICE"

  validation {
    condition     = contains(["NONE", "SERVICE", "TASK_DEFINITION"], upper(var.propagate_tags))
    error_message = "propagate_tags must be NONE, SERVICE, or TASK_DEFINITION."
  }
}

variable "wait_for_steady_state" {
  description = "Wait for ECS service to reach steady state."
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Force new deployment on each apply."
  type        = bool
  default     = false
}

variable "enable_load_balancer" {
  description = "Attach ECS service to an ALB target group."
  type        = bool
  default     = true
}

variable "create_alb" {
  description = "Create ALB and target group using alb module."
  type        = bool
  default     = true
}

variable "alb_target_group_arn" {
  description = "Existing ALB target group ARN used when create_alb is false."
  type        = string
  default     = null
}

variable "alb_name" {
  description = "Optional explicit ALB base name."
  type        = string
  default     = null
}

variable "alb_internal" {
  description = "Whether ALB is internal."
  type        = bool
  default     = false
}

variable "alb_subnet_ids" {
  description = "Subnet IDs used by ALB."
  type        = list(string)
  default     = []
}

variable "create_alb_security_group" {
  description = "Create security group for ALB."
  type        = bool
  default     = true
}

variable "alb_security_group_name" {
  description = "Optional explicit ALB security group name."
  type        = string
  default     = null
}

variable "alb_security_group_ids" {
  description = "Existing security groups attached to ALB when create_alb_security_group is false."
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidr_blocks" {
  description = "IPv4 CIDR ranges allowed to reach ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 80

  validation {
    condition     = var.alb_listener_port >= 1 && var.alb_listener_port <= 65535
    error_message = "alb_listener_port must be between 1 and 65535."
  }
}

variable "alb_listener_protocol" {
  description = "ALB listener protocol."
  type        = string
  default     = "HTTP"

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
  description = "Optional explicit ALB target group port. Defaults to container_port."
  type        = number
  default     = null

  validation {
    condition     = var.alb_target_group_port == null || try(var.alb_target_group_port >= 1 && var.alb_target_group_port <= 65535, false)
    error_message = "alb_target_group_port must be between 1 and 65535 when provided."
  }
}

variable "alb_target_group_protocol" {
  description = "Protocol used by ALB target group."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.alb_target_group_protocol))
    error_message = "alb_target_group_protocol must be HTTP or HTTPS."
  }
}

variable "alb_protocol_version" {
  description = "Optional ALB target group protocol version."
  type        = string
  default     = null

  validation {
    condition = var.alb_protocol_version == null || contains([
      "HTTP1",
      "HTTP2",
      "GRPC"
    ], upper(var.alb_protocol_version))
    error_message = "alb_protocol_version must be HTTP1, HTTP2, GRPC, or null."
  }
}

variable "alb_deregistration_delay" {
  description = "Deregistration delay in seconds for target group."
  type        = number
  default     = 30

  validation {
    condition     = var.alb_deregistration_delay >= 0 && var.alb_deregistration_delay <= 3600
    error_message = "alb_deregistration_delay must be between 0 and 3600."
  }
}

variable "alb_idle_timeout" {
  description = "Idle timeout in seconds for ALB connections."
  type        = number
  default     = 60

  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000
    error_message = "alb_idle_timeout must be between 1 and 4000."
  }
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB."
  type        = bool
  default     = false
}

variable "alb_health_check_path" {
  description = "Health check path for ALB target group."
  type        = string
  default     = "/"
}

variable "alb_health_check_matcher" {
  description = "Health check matcher for ALB target group."
  type        = string
  default     = "200-399"
}

variable "alb_health_check_interval" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.alb_health_check_interval >= 5 && var.alb_health_check_interval <= 300
    error_message = "alb_health_check_interval must be between 5 and 300."
  }
}

variable "alb_health_check_timeout" {
  description = "Health check timeout in seconds."
  type        = number
  default     = 5

  validation {
    condition     = var.alb_health_check_timeout >= 2 && var.alb_health_check_timeout <= 120
    error_message = "alb_health_check_timeout must be between 2 and 120."
  }
}

variable "alb_health_check_healthy_threshold" {
  description = "Healthy threshold for ALB target group health check."
  type        = number
  default     = 3

  validation {
    condition     = var.alb_health_check_healthy_threshold >= 2 && var.alb_health_check_healthy_threshold <= 10
    error_message = "alb_health_check_healthy_threshold must be between 2 and 10."
  }
}

variable "alb_health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for ALB target group health check."
  type        = number
  default     = 3

  validation {
    condition     = var.alb_health_check_unhealthy_threshold >= 2 && var.alb_health_check_unhealthy_threshold <= 10
    error_message = "alb_health_check_unhealthy_threshold must be between 2 and 10."
  }
}

variable "alb_stickiness_enabled" {
  description = "Enable ALB target group stickiness."
  type        = bool
  default     = false
}

variable "alb_stickiness_cookie_duration" {
  description = "Cookie duration in seconds when stickiness is enabled."
  type        = number
  default     = 86400

  validation {
    condition     = var.alb_stickiness_cookie_duration >= 1 && var.alb_stickiness_cookie_duration <= 604800
    error_message = "alb_stickiness_cookie_duration must be between 1 and 604800."
  }
}

variable "alb_create_acm_certificate" {
  description = "Create ACM certificate in ALB module and attach to HTTPS listener."
  type        = bool
  default     = false
}

variable "alb_acm_domain_name" {
  description = "Primary domain name used by ACM certificate created through ALB module."
  type        = string
  default     = null
}

variable "alb_acm_subject_alternative_names" {
  description = "Optional ACM SAN entries."
  type        = list(string)
  default     = []
}

variable "alb_acm_validation_method" {
  description = "Validation method used by ACM certificate."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], upper(var.alb_acm_validation_method))
    error_message = "alb_acm_validation_method must be DNS or EMAIL."
  }
}

variable "alb_acm_hosted_zone_id" {
  description = "Route53 hosted zone ID used by ACM validation."
  type        = string
  default     = null
}

variable "alb_acm_create_route53_records" {
  description = "Create Route53 records for ACM DNS validation."
  type        = bool
  default     = true
}

variable "alb_acm_validation_record_ttl" {
  description = "TTL in seconds for ACM DNS validation records."
  type        = number
  default     = 60

  validation {
    condition     = var.alb_acm_validation_record_ttl >= 1 && var.alb_acm_validation_record_ttl <= 172800
    error_message = "alb_acm_validation_record_ttl must be between 1 and 172800."
  }
}

variable "alb_acm_wait_for_validation" {
  description = "Whether Terraform should wait for ACM validation."
  type        = bool
  default     = true
}

variable "alb_acm_certificate_tags" {
  description = "Additional tags for ACM certificate created through ALB module."
  type        = map(string)
  default     = {}
}

variable "enable_service_autoscaling" {
  description = "Enable ECS service desired count autoscaling."
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum ECS service desired count when autoscaling is enabled."
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaling_min_capacity >= 0
    error_message = "autoscaling_min_capacity must be greater than or equal to 0."
  }
}

variable "autoscaling_max_capacity" {
  description = "Maximum ECS service desired count when autoscaling is enabled."
  type        = number
  default     = 3

  validation {
    condition     = var.autoscaling_max_capacity >= 1
    error_message = "autoscaling_max_capacity must be greater than or equal to 1."
  }
}

variable "autoscaling_cpu_target_value" {
  description = "CPU utilization target used by ECS service autoscaling policy."
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_cpu_target_value > 0
    error_message = "autoscaling_cpu_target_value must be greater than 0."
  }
}

variable "autoscaling_memory_target_value" {
  description = "Memory utilization target used by ECS service autoscaling policy."
  type        = number
  default     = 75

  validation {
    condition     = var.autoscaling_memory_target_value > 0
    error_message = "autoscaling_memory_target_value must be greater than 0."
  }
}

variable "autoscaling_scale_in_cooldown" {
  description = "Scale-in cooldown in seconds for autoscaling policies."
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_scale_in_cooldown >= 0
    error_message = "autoscaling_scale_in_cooldown must be greater than or equal to 0."
  }
}

variable "autoscaling_scale_out_cooldown" {
  description = "Scale-out cooldown in seconds for autoscaling policies."
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_scale_out_cooldown >= 0
    error_message = "autoscaling_scale_out_cooldown must be greater than or equal to 0."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags for ECS cluster."
  type        = map(string)
  default     = {}
}

variable "task_definition_tags" {
  description = "Additional tags for ECS task definition."
  type        = map(string)
  default     = {}
}

variable "service_tags" {
  description = "Additional tags for ECS service."
  type        = map(string)
  default     = {}
}

variable "execution_role_tags" {
  description = "Additional tags for created execution role."
  type        = map(string)
  default     = {}
}

variable "task_role_tags" {
  description = "Additional tags for created task role."
  type        = map(string)
  default     = {}
}

variable "service_security_group_tags" {
  description = "Additional tags for created ECS service security group."
  type        = map(string)
  default     = {}
}

variable "alb_security_group_tags" {
  description = "Additional tags for created ALB security group."
  type        = map(string)
  default     = {}
}

variable "log_group_tags" {
  description = "Additional tags for created CloudWatch log group."
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
