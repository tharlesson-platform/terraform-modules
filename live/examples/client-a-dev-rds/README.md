# Example: client-a-dev-rds

## Purpose
Exemplo funcional do stack **rds** em contexto **client-a / dev**.

## Module Composition
- source = "../../../modules/rds"

## Why This Example Exists
- Servir como baseline para novos clientes ou novos ambientes.
- Demonstrar estrutura minima de arquivos para execucao segura.
- Facilitar onboarding tecnico e revisao de padroes.

## Environment Context
- `region      = "us-east-1"`
- Parametros em `terraform.tfvars`.

## Outputs
- `rds_endpoint`
- `rds_reader_endpoint`
- `rds_port`
- `rds_cluster_id`
- `rds_writer_instance_id`
- `rds_reader_instance_ids`
- `rds_subnet_group_name`
- `discovered_subnet_ids`
- `selected_subnet_source`
- `rds_security_group_ids`
- `master_user_secret_arn`
- `enhanced_monitoring_role_arn`
- `rds_storage_kms_key_arn`
- `rds_master_secret_kms_key_arn`

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