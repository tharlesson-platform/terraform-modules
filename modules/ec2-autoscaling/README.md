# Module: EC2 Auto Scaling

## Purpose
Provisiona Auto Scaling Group para EC2 com launch template, rede, IAM profile e politicas de escala.

## What This Module Builds
- `aws_launch_template` com AMI, user data, metadata options e block devices opcionais.
- `aws_autoscaling_group` com capacidade min/max/desired e integracao opcional com target groups.
- Security group opcional com regras de ingress/egress.
- IAM role + instance profile opcionais para as instancias.
- Politicas opcionais de target tracking (incluindo CPU).

## Key Inputs
- `name`, `instance_type`, `vpc_id`, `subnet_ids`
- `ami_id` ou resolucao via SSM (`resolve_ami_from_ssm`)
- `create_security_group`, `security_group_ingress_rules`
- `create_instance_profile`, `iam_role_policy_arns`
- `min_size`, `desired_capacity`, `max_size`
- `cpu_target_tracking_enabled`, `target_tracking_policies`

## Key Outputs
- `autoscaling_group_name`, `autoscaling_group_arn`
- `launch_template_id`, `launch_template_latest_version`
- `resolved_subnet_ids`
- `resolved_security_group_ids`
- `iam_instance_profile_name`
- `cpu_target_tracking_policy_arn`

## Where It Is Used
- `live/client-a/*/ec2-autoscaling`
- `live/examples/client-a-dev-ec2-autoscaling`

## Notes
Para workload HTTP em producao, combine este modulo com ALB target group e health check tipo `ELB`.
