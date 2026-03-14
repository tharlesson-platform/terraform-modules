# Stack: client-a / stg / ecs

## Purpose
Implementa o stack **ecs** no ambiente **stg** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/ecs"
- Reutiliza internamente `modules/alb` e `modules/acm` quando habilitado.

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-stg"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Depende de VPC para `vpc_id`, `service_subnet_ids` e `alb_subnet_ids`.
- Pode consumir cluster ECS existente quando `create_cluster = false`.
- Pode consumir target group existente quando `create_alb = false`.

## Outputs
- `ecs_cluster_arn`
- `ecs_cluster_name`
- `ecs_service_name`
- `ecs_service_arn`
- `ecs_task_definition_arn`
- `ecs_service_security_group_ids`
- `alb_dns_name`
- `alb_target_group_arn`
- `alb_acm_certificate_arn`

## Files in This Stack
- `main.tf`: chamada do modulo e outputs locais.
- `provider.tf`: provider AWS e default tags.
- `variables.tf`: contrato de variaveis da stack.
- `terraform.tfvars`: valores do ambiente.
- `versions.tf`: constraints de Terraform/provider.

## How to Execute
```bash
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

## Operational Notes
- Ajuste `backend.hcl` para bucket/key/region corretos antes da primeira execucao; o lock agora usa `.tflock` no S3.
- Revise `terraform.tfvars` (dominio ACM, subnets, VPC e imagem) antes de aplicar.
