# Stack: client-a / prod / security-baseline

## Purpose
Implementa o stack **security-baseline** no ambiente **prod** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/security-baseline"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-prod"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Sem dependencia dura. Recomendado aplicar cedo no ambiente.

## Outputs
- `audit_bucket_name`
- `cloudtrail_arn`
- `config_role_arn`
- `config_recorder_name`
- `kms_key_arn`

## Files in This Stack
- `main.tf`: chamada do modulo e outputs locais.
- `provider.tf`: provider AWS e default tags.
- `variables.tf`: contrato de variaveis da stack.
- `terraform.tfvars`: valores do ambiente.
- `backend.hcl`: configuracao de backend remoto.
- `versions.tf`: constraints de Terraform/provider.

## How to Execute
```bash
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

## Operational Notes
- Ajuste `backend.hcl` para bucket/key/table corretos antes da primeira execucao.
- Revise `terraform.tfvars` antes de promover alteracoes entre ambientes.