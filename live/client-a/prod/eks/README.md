# Stack: client-a / prod / eks

## Purpose
Implementa o stack **eks** no ambiente **prod** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/eks"
- Reutiliza internamente `modules/alb` e `modules/acm` quando habilitado.

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-prod"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Depende de VPC para `vpc_id`, `cluster_subnet_ids`, `node_subnet_ids` e `alb_subnet_ids`.
- Pode consumir IAM roles existentes quando `create_cluster_role = false` e/ou `create_node_role = false`.
- Pode consumir target group existente quando `create_alb = false`.

## Outputs
- `eks_cluster_arn`
- `eks_cluster_name`
- `eks_cluster_endpoint`
- `eks_cluster_version`
- `eks_oidc_provider_arn`
- `eks_node_group_arns`
- `eks_control_plane_security_group_id`
- `eks_node_security_group_ids`
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
- Ajuste `backend.hcl` para bucket/key/table corretos antes da primeira execucao.
- Revise `terraform.tfvars` (subnets, VPC, dominio ACM e hosted zone) antes de aplicar.
