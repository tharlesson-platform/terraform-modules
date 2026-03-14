# Example: client-a-dev-s3

## Purpose
Exemplo funcional do stack **s3** em contexto **client-a / dev**.

## Module Composition
- source = "../../../modules/s3"

## Why This Example Exists
- Servir como baseline para novos clientes ou novos ambientes.
- Demonstrar estrutura minima de arquivos para execucao segura.
- Facilitar onboarding tecnico e revisao de padroes.

## Environment Context
- `region      = "us-east-1"`
- Parametros em `terraform.tfvars`.

## Outputs
- `bucket_name`
- `bucket_arn`
- `bucket_regional_domain_name`

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
- `backend.hcl`
- `versions.tf`