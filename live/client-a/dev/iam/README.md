# Stack: client-a / dev / iam

## Purpose
Implementa o stack **iam** no ambiente **dev** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/iam-workload-roles"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-dev"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Sem dependencia dura de outras stacks.

## Outputs
- `workload_role_names`
- `workload_role_arns`
- `terraform_deploy_role_name`
- `terraform_deploy_role_arn`

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
- Ajuste `backend.hcl` para bucket/key/region corretos antes da primeira execucao; o lock agora usa `.tflock` no S3.
- Revise `terraform.tfvars` antes de promover alteracoes entre ambientes.