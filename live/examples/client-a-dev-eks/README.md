# Example: client-a-dev-eks

## Purpose
Exemplo funcional do stack **eks** em contexto **client-a / dev**.

## Module Composition
- source = "../../../modules/eks"
- Reutiliza internamente `modules/alb` e `modules/acm` quando habilitado.

## Why This Example Exists
- Servir como baseline para novos clientes ou novos ambientes.
- Demonstrar estrutura minima de arquivos para execucao segura.
- Facilitar onboarding tecnico e revisao de padroes.

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-dev"`
- Arquivo principal de parametros: `terraform.tfvars`

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

## How to Use This Example
1. Copie o diretorio para um novo contexto (cliente/ambiente).
2. Ajuste `terraform.tfvars`.
3. Ajuste `backend.hcl` (bucket/key/region; lock via `.tflock` no S3).
4. Rode Terraform.

```bash
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

## Files in This Example
- `main.tf`
- `provider.tf`
- `variables.tf`
- `terraform.tfvars`
- `versions.tf`
