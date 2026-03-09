# Stack: client-a / prod / vpc

## Purpose
Implementa o stack **vpc** no ambiente **prod** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/vpc"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-prod"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Base de networking. Geralmente aplicada antes das demais stacks.

## Outputs
- `vpc_id`
- `private_subnet_ids`
- `database_subnet_group_name`

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