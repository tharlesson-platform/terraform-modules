# Module: EC2

## Purpose
Provisiona instancias EC2 com opcoes de rede, bootstrap, IAM profile e armazenamento.

## What This Module Builds
- aws_instance com controles de metadata e runtime.
- Descoberta opcional de subnet privada quando subnet_id = null.
- Security group opcional com regras de ingress/egress.
- Key pair opcional.
- IAM role/instance profile opcionais.
- Elastic IP opcional.
- Root e EBS block devices opcionais.

## Key Inputs
- name, instance_type, vpc_id, subnet_id
- ami_id ou resolucao via SSM (resolve_ami_from_ssm)
- create_security_group, security_group_ingress_rules
- create_instance_profile, iam_role_policy_arns
- user_data, manage_root_block_device, ebs_block_devices

## Key Outputs
- ec2_instance_id, ec2_private_ip, ec2_public_ip
- ec2_security_group_ids
- iam_instance_profile_name
- elastic_ip_public_ip

## Where It Is Used
- live/client-a/*/ec2
- live/examples/client-a-dev-ec2

## Notes
Em producao, prefira subnet privada e acesso via SSM para reduzir superficie de ataque.