# Example: client-a-dev-security-baseline

## Purpose
Exemplo funcional do stack **security-baseline** em contexto **client-a / dev**.

## Module Composition
- source = "../../../modules/security-baseline"

## Why This Example Exists
- Servir como baseline para novos clientes ou novos ambientes.
- Demonstrar estrutura minima de arquivos para execucao segura.
- Facilitar onboarding tecnico e revisao de padroes.

## Environment Context
- `region      = "us-east-1"`
- Parametros em `terraform.tfvars`.

## Outputs
- `audit_bucket_name`
- `cloudtrail_arn`
- `config_role_arn`
- `config_recorder_name`
- `kms_key_arn`

## How to Use This Example
1. Copie o diretorio para um novo contexto (cliente/ambiente).
2. Ajuste `terraform.tfvars`.
3. Ajuste `backend.hcl`.
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