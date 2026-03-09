# Module: RDS

## Purpose
Provisiona banco relacional AWS RDS com controles de seguranca, operacao e lifecycle.

## What This Module Builds
- aws_db_instance com parametros de engine e storage.
- Security group dedicado (opcional) e regras de acesso.
- DB subnet group novo ou reutilizacao de existente.
- Parameter group customizavel (opcional).
- Integracoes de observabilidade (logs/monitoring/performance insights).

## Key Inputs
- name, identifier, engine, engine_version, instance_class
- allocated_storage, max_allocated_storage, storage_type
- vpc_id, db_subnet_group_name
- allowed_cidr_blocks, allowed_security_group_ids
- backup_retention_period, multi_az, deletion_protection

## Key Outputs
- db_instance_id, db_instance_arn, db_instance_endpoint
- db_instance_address, db_instance_port, db_instance_status
- security_group_ids, master_user_secret_arn

## Where It Is Used
- live/client-a/*/rds
- live/examples/client-a-dev-rds

## Notes
Este modulo depende de networking pronto (VPC e DB subnet group).