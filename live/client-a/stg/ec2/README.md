# Stack: client-a / stg / ec2

## Purpose
Implementa o stack **ec2** no ambiente **stg** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/ec2"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-stg"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Depende de VPC (subnet/vpc_id).
- Pode depender de IAM para roles customizadas.

## Outputs
- `ec2_instance_id`
- `ec2_private_ip`
- `ec2_public_ip`
- `ec2_security_group_ids`
- `ec2_iam_instance_profile_name`
- `ec2_elastic_ip`
- `ec2_resolved_subnet_id`
- `ec2_discovered_private_subnet_ids`

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