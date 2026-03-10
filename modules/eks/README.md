# Module: EKS

## Purpose
Provisiona um cluster EKS com node groups gerenciados, IAM, security groups, OIDC e composicao opcional de ALB + ACM para ingress.

## What This Module Builds
- `aws_eks_cluster` com endpoint publico/privado e logs de control plane.
- IAM role do control plane (opcional) e IAM role de node groups (opcional).
- Security groups para control plane, workers e ALB (opcionais).
- `aws_eks_node_group` para um ou mais pools gerenciados.
- `aws_iam_openid_connect_provider` opcional para IRSA.
- `module.alb` opcional, com suporte a certificado via `module.acm`.

## Key Inputs
- `name`, `cluster_name`, `cluster_version`
- `vpc_id`, `cluster_subnet_ids`, `node_subnet_ids`
- `create_cluster_role`/`cluster_role_arn`
- `create_node_role`/`node_role_arn`
- `managed_node_groups`
- `enable_ingress_alb`, `create_alb`, `alb_*`
- `alb_create_acm_certificate`, `alb_acm_*`

## Key Outputs
- `cluster_arn`, `cluster_name`, `cluster_endpoint`, `cluster_version`
- `cluster_certificate_authority_data`
- `oidc_provider_arn`, `cluster_oidc_issuer_url`
- `node_group_arns`, `node_group_status`
- `ingress_alb_load_balancer_dns_name`
- `ingress_target_group_arn`
- `ingress_alb_acm_certificate_arn`

## Notes
- Quando `create_alb = false`, informe `alb_target_group_arn`.
- Para listener HTTPS, informe `alb_listener_certificate_arn` ou habilite `alb_create_acm_certificate`.
- Para node groups sem `subnet_ids` por grupo, informe `node_subnet_ids` no nivel global.
