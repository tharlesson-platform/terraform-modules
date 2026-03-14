# Example: client-a-dev-ec2

## Purpose
Exemplo funcional do stack **ec2** em contexto **client-a / dev**.

## Module Composition
- source = "../../../modules/ec2"

## Why This Example Exists
- Servir como baseline para novos clientes ou novos ambientes.
- Demonstrar estrutura minima de arquivos para execucao segura.
- Facilitar onboarding tecnico e revisao de padroes.

## Environment Context
- `region      = "us-east-1"`
- Parametros em `terraform.tfvars`.

## Outputs
- `ec2_instance_id`
- `ec2_private_ip`
- `ec2_public_ip`
- `ec2_security_group_ids`
- `ec2_iam_instance_profile_name`
- `ec2_elastic_ip`
- `ec2_resolved_subnet_id`
- `ec2_discovered_private_subnet_ids`

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