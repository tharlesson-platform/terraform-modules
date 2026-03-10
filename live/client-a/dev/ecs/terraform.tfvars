region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-ecs-client-a-dev"

client        = "client-a"
environment   = "dev"
workload_name = "app"

cluster_name           = null
create_cluster         = true
existing_cluster_arn   = null
service_name           = null
task_definition_family = null

enable_container_insights = true

container_image      = "public.ecr.aws/nginx/nginx:stable"
container_name       = null
container_port       = 80
container_protocol   = "tcp"
container_command    = null
container_entrypoint = null
container_environment = {
  APP_ENV = "dev"
}
container_secrets = []

task_cpu         = 256
task_memory      = 512
network_mode     = "awsvpc"
launch_type      = "FARGATE"
platform_version = "LATEST"

create_cloudwatch_log_group = true
log_group_name              = null
log_group_retention_in_days = 30
log_group_kms_key_id        = null

create_execution_role               = true
execution_role_arn                  = null
execution_role_name                 = null
execution_role_permissions_boundary = null
execution_role_policy_arns          = []

create_task_role               = true
task_role_arn                  = null
task_role_name                 = null
task_role_permissions_boundary = null
task_role_policy_arns          = []

# Output do stack vpc
vpc_id = "vpc-0123456789abcdef0"
service_subnet_ids = [
  "subnet-0privatea",
  "subnet-0privateb"
]

assign_public_ip              = false
create_service_security_group = true
service_security_group_name   = null
service_security_group_ids    = []
service_ingress_cidr_blocks   = []
service_egress_cidr_blocks = [
  "0.0.0.0/0"
]

desired_count                      = 1
scheduling_strategy                = "REPLICA"
deployment_minimum_healthy_percent = 50
deployment_maximum_percent         = 200
health_check_grace_period_seconds  = 60
enable_execute_command             = true
enable_ecs_managed_tags            = true
propagate_tags                     = "SERVICE"
wait_for_steady_state              = false
force_new_deployment               = false

enable_load_balancer = true
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
alb_listener_port            = 443
alb_listener_protocol        = "HTTPS"
alb_listener_ssl_policy      = null
alb_listener_certificate_arn = null
alb_target_group_name        = null
alb_target_group_port        = 80
alb_target_group_protocol    = "HTTP"
alb_health_check_path        = "/"
alb_health_check_matcher     = "200-399"

alb_create_acm_certificate        = true
alb_acm_domain_name               = "app.dev.client-a.example.com"
alb_acm_subject_alternative_names = []
alb_acm_validation_method         = "DNS"
alb_acm_hosted_zone_id            = "Z1234567890EXAMPLE"
alb_acm_create_route53_records    = true
alb_acm_wait_for_validation       = true

enable_service_autoscaling      = true
autoscaling_min_capacity        = 1
autoscaling_max_capacity        = 2
autoscaling_cpu_target_value    = 60
autoscaling_memory_target_value = 75
autoscaling_scale_in_cooldown   = 60
autoscaling_scale_out_cooldown  = 60

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}
