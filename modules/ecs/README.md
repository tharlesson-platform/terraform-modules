# Module: ECS

## Purpose
Provisiona workload em ECS com service Fargate/EC2, task definition, IAM roles e integracao opcional com ALB + ACM.

## What This Module Builds
- `aws_ecs_cluster` opcional.
- `aws_ecs_task_definition` para container principal.
- `aws_ecs_service` com network configuration e ECS Exec.
- IAM roles de execution e task (opcionais).
- Security groups para service e ALB (opcionais).
- `module.alb` opcional, com suporte a ACM via modulo `acm`.
- Autoscaling opcional para desired count com politicas de CPU e memoria.

## Key Inputs
- `name`, `container_image`, `service_subnet_ids`
- `create_cluster`/`existing_cluster_arn`
- `create_execution_role`/`execution_role_arn`
- `create_task_role`/`task_role_arn`
- `enable_load_balancer`, `create_alb`, `alb_*`
- `alb_create_acm_certificate`, `alb_acm_*`
- `enable_service_autoscaling`, `autoscaling_*`

## Key Outputs
- `cluster_arn`, `cluster_name`
- `service_name`, `service_arn`
- `task_definition_arn`
- `resolved_service_security_group_ids`
- `alb_load_balancer_arn`, `alb_load_balancer_dns_name`
- `alb_target_group_arn`
- `alb_acm_certificate_arn`

## Notes
- Quando `enable_load_balancer = true` e `create_alb = false`, informe `alb_target_group_arn`.
- Para listener HTTPS, informe `alb_listener_certificate_arn` ou habilite `alb_create_acm_certificate`.
- Para Fargate, o modulo exige `network_mode = "awsvpc"` e `launch_type = "FARGATE"`.
