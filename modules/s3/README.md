# Module: S3

## Purpose
Provisiona buckets S3 com guardrails de seguranca e configuracoes operacionais.

## What This Module Builds
- Bucket com ownership controls.
- Public access block completo.
- Versionamento.
- Criptografia SSE (AES256 ou aws:kms).
- Lifecycle opcional.
- Policy opcional.
- Access logging opcional.

## Key Inputs
- bucket_name, force_destroy
- object_ownership, versioning_status
- sse_algorithm, kms_key_arn, bucket_key_enabled
- lifecycle_*
- bucket_policy_json

## Key Outputs
- bucket_name, bucket_arn
- bucket_regional_domain_name
- versioning_status, sse_algorithm
- lifecycle_enabled, access_logging_enabled

## Where It Is Used
- live/client-a/*/s3
- live/examples/client-a-dev-s3

## Notes
Nomes de bucket devem ser globalmente unicos na AWS.