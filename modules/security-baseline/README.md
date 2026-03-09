# Module: Security Baseline

## Purpose
Cria baseline de seguranca e auditoria para conta AWS.

## What This Module Builds
- KMS key e alias para criptografia de logs.
- Bucket S3 de auditoria com hardening.
- CloudTrail multi-region com validacao de integridade.
- AWS Config (role, recorder e delivery channel).

## Key Inputs
- name_prefix, audit_bucket_name, kms_alias_name
- enable_cloudtrail, is_multi_region_trail
- config_snapshot_delivery_frequency
- log_expiration_days, force_destroy_bucket

## Key Outputs
- kms_key_arn
- audit_bucket_name, audit_bucket_arn
- cloudtrail_arn
- config_role_arn, config_recorder_name

## Where It Is Used
- live/client-a/*/security-baseline
- live/examples/client-a-dev-security-baseline

## Notes
Recomendado como primeiro stack em ambientes novos para garantir trilha de auditoria desde o inicio.