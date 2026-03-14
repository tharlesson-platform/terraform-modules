# Stack: client-a / stg / ec2-autoscaling

## Purpose
Implementa o stack **ec2-autoscaling** no ambiente **stg** para o cliente **client-a**.

## Module Composition
- source = "../../../../modules/ec2-autoscaling"

## Environment Context
- `region      = "us-east-1"`
- `aws_profile = "client-a-stg"`
- Arquivo principal de parametros: `terraform.tfvars`

## Dependencies
- Depende de VPC (subnets privadas e vpc_id).
- Pode depender de ALB/NLB target groups quando `target_group_arns` for utilizado.

## Outputs
- `autoscaling_group_name`
- `autoscaling_group_arn`
- `launch_template_id`
- `resolved_subnet_ids`
- `resolved_security_group_ids`
- `iam_instance_profile_name`
- `cpu_target_tracking_policy_arn`

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
