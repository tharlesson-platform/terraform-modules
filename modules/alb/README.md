# Module: ALB

## Purpose
Provisiona Application Load Balancer com target group, listener e health check configuravel.

## What This Module Builds
- `aws_lb` tipo `application`.
- `aws_lb_target_group` opcional com health check e stickiness.
- `module.acm` opcional para criar e validar certificado ACM.
- `aws_lb_listener` com acao `forward`, `redirect` ou `fixed-response`.
- `aws_lb_target_group_attachment` opcional para registrar targets.

## Key Inputs
- `name`, `subnet_ids`, `security_group_ids`
- `create_target_group`, `vpc_id`, `target_group_port`, `target_group_protocol`
- `health_check_*`
- `listener_port`, `listener_protocol`, `listener_default_action_type`
- `listener_certificate_arn` ou `create_acm_certificate` + `acm_*`
- `target_attachments`

## Key Outputs
- `load_balancer_arn`, `load_balancer_dns_name`
- `listener_arn`
- `listener_certificate_arn`
- `target_group_arn`
- `acm_certificate_arn`
- `target_attachment_ids`

## Notes
- Quando `listener_default_action_type = "forward"`, o modulo precisa resolver um target group (`create_target_group = true` ou `target_group_arn` informado).
- Para listener HTTPS, informe `listener_certificate_arn` ou habilite `create_acm_certificate`.
