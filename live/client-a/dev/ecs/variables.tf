variable "region" {
  description = "AWS region."
  type        = string
}

variable "aws_profile" {
  description = "Optional AWS CLI profile."
  type        = string
  default     = null
}

variable "aws_assume_role_arn" {
  description = "Optional IAM Role ARN to assume in target AWS account."
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name used when assuming role."
  type        = string
  default     = "terraform-ecs"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "workload_name" {
  description = "Workload suffix used in ECS naming."
  type        = string
  default     = "app"
}

variable "cluster_name" {
  description = "Optional explicit ECS cluster name."
  type        = string
  default     = null
}

variable "create_cluster" {
  description = "Create ECS cluster in this stack."
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
  description = "Enable ECS container insights."
  type        = bool
  default     = true
}

variable "container_image" {
  description = "Container image used by ECS service."
  type        = string
}

variable "container_name" {
  description = "Optional explicit container name."
  type        = string
  default     = null
}

variable "container_port" {
  description = "Container port exposed by ECS service."
  type        = number
  default     = 80
}

variable "container_protocol" {
  description = "Container transport protocol."
  type        = string
  default     = "tcp"
}

variable "container_command" {
  description = "Optional command array for container."
  type        = list(string)
  default     = null
}

variable "container_entrypoint" {
  description = "Optional entrypoint array for container."
  type        = list(string)
  default     = null
}

variable "container_environment" {
  description = "Environment variables map for container."
  type        = map(string)
  default     = {}
}

variable "container_secrets" {
  description = "Secret definitions for container."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

variable "task_cpu" {
  description = "Task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 512
}

variable "network_mode" {
  description = "Task definition network mode."
  type        = string
  default     = "awsvpc"
}

variable "launch_type" {
  description = "ECS launch type."
  type        = string
  default     = "FARGATE"
}

variable "platform_version" {
  description = "ECS platform version for Fargate."
  type        = string
  default     = "LATEST"
}

variable "create_cloudwatch_log_group" {
  description = "Create CloudWatch log group."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Optional explicit CloudWatch log group name."
  type        = string
  default     = null
}

variable "log_group_retention_in_days" {
  description = "Log retention in days."
  type        = number
  default     = 30
}

variable "log_group_kms_key_id" {
  description = "Optional KMS key ID for log group."
  type        = string
  default     = null
}

variable "create_execution_role" {
  description = "Create ECS execution role."
  type        = bool
  default     = true
}

variable "execution_role_arn" {
  description = "Existing execution role ARN when create_execution_role is false."
  type        = string
  default     = null
}

variable "execution_role_name" {
  description = "Optional explicit execution role name."
  type        = string
  default     = null
}

variable "execution_role_permissions_boundary" {
  description = "Optional permissions boundary for execution role."
  type        = string
  default     = null
}

variable "execution_role_policy_arns" {
  description = "Additional managed policy ARNs for execution role."
  type        = list(string)
  default     = []
}

variable "create_task_role" {
  description = "Create ECS task role."
  type        = bool
  default     = true
}

variable "task_role_arn" {
  description = "Existing task role ARN when create_task_role is false."
  type        = string
  default     = null
}

variable "task_role_name" {
  description = "Optional explicit task role name."
  type        = string
  default     = null
}

variable "task_role_permissions_boundary" {
  description = "Optional permissions boundary for task role."
  type        = string
  default     = null
}

variable "task_role_policy_arns" {
  description = "Managed policy ARNs for task role."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID used by ECS and ALB security groups."
  type        = string
}

variable "service_subnet_ids" {
  description = "Subnet IDs used by ECS service."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks."
  type        = bool
  default     = false
}

variable "create_service_security_group" {
  description = "Create ECS service security group."
  type        = bool
  default     = true
}

variable "service_security_group_name" {
  description = "Optional explicit ECS service security group name."
  type        = string
  default     = null
}

variable "service_security_group_ids" {
  description = "Existing security groups used by ECS service."
  type        = list(string)
  default     = []
}

variable "service_ingress_cidr_blocks" {
  description = "Additional CIDRs allowed to reach ECS service container port."
  type        = list(string)
  default     = []
}

variable "service_egress_cidr_blocks" {
  description = "CIDRs allowed for ECS service outbound traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "scheduling_strategy" {
  description = "ECS scheduling strategy."
  type        = string
  default     = "REPLICA"
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent for deployments."
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Maximum deployment percent."
  type        = number
  default     = 200
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds."
  type        = number
  default     = 60
}

variable "enable_execute_command" {
  description = "Enable ECS Exec."
  type        = bool
  default     = true
}

variable "enable_ecs_managed_tags" {
  description = "Enable ECS managed tags."
  type        = bool
  default     = true
}

variable "propagate_tags" {
  description = "Tag propagation strategy."
  type        = string
  default     = "SERVICE"
}

variable "wait_for_steady_state" {
  description = "Wait for ECS service steady state."
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Force new deployment on each apply."
  type        = bool
  default     = false
}

variable "enable_load_balancer" {
  description = "Attach ECS service to ALB target group."
  type        = bool
  default     = true
}

variable "create_alb" {
  description = "Create ALB in this stack."
  type        = bool
  default     = true
}

variable "alb_target_group_arn" {
  description = "Existing target group ARN when create_alb is false."
  type        = string
  default     = null
}

variable "alb_name" {
  description = "Optional explicit ALB name."
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
  description = "Existing security groups used by ALB."
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDRs allowed to reach ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "ALB listener protocol."
  type        = string
  default     = "HTTP"
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
  description = "Optional explicit ALB target group port."
  type        = number
  default     = null
}

variable "alb_target_group_protocol" {
  description = "ALB target group protocol."
  type        = string
  default     = "HTTP"
}

variable "alb_health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/"
}

variable "alb_health_check_matcher" {
  description = "ALB target group health check matcher."
  type        = string
  default     = "200-399"
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

variable "alb_acm_wait_for_validation" {
  description = "Wait for ACM certificate validation."
  type        = bool
  default     = true
}

variable "enable_service_autoscaling" {
  description = "Enable ECS service autoscaling."
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum desired count for autoscaling."
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum desired count for autoscaling."
  type        = number
  default     = 3
}

variable "autoscaling_cpu_target_value" {
  description = "CPU target value for autoscaling policy."
  type        = number
  default     = 60
}

variable "autoscaling_memory_target_value" {
  description = "Memory target value for autoscaling policy."
  type        = number
  default     = 75
}

variable "autoscaling_scale_in_cooldown" {
  description = "Scale-in cooldown in seconds."
  type        = number
  default     = 60
}

variable "autoscaling_scale_out_cooldown" {
  description = "Scale-out cooldown in seconds."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
