# Module: ACM

## Purpose
Provisiona certificado ACM com validacao DNS (Route53 opcional) ou EMAIL.

## What This Module Builds
- `aws_acm_certificate` para dominio principal e SANs opcionais.
- `aws_route53_record` opcionais para validacao DNS automatica.
- `aws_acm_certificate_validation` opcional para aguardar validacao no apply.

## Key Inputs
- `domain_name`, `subject_alternative_names`
- `validation_method`
- `hosted_zone_id`, `create_route53_records`, `validation_record_ttl`
- `wait_for_validation`

## Key Outputs
- `certificate_arn`
- `certificate_domain_name`
- `certificate_status`
- `validation_record_fqdns`

## Notes
- Para automacao completa com DNS, use `validation_method = "DNS"` com `create_route53_records = true` e `hosted_zone_id` informado.
- Quando `wait_for_validation = true`, o apply aguarda o certificado ficar valido.
