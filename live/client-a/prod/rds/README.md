# Stack: client-a / prod / rds

## Purpose
Implementa o stack **rds** no ambiente **prod** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/rds"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-prod"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Depende de saidas da stack VPC (vpc_id, db_subnet_group_name).

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