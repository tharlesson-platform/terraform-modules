locals {
  normalized_validation_method = upper(var.validation_method)

  create_dns_validation_records = local.normalized_validation_method == "DNS" && var.create_route53_records

  domain_validation_options_by_name = {
    for option in aws_acm_certificate.this.domain_validation_options :
    option.domain_name => {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "acm"
    Domain    = var.domain_name
  })
}

check "route53_validation_records_require_dns_validation_method" {
  assert {
    condition     = !var.create_route53_records || local.normalized_validation_method == "DNS"
    error_message = "create_route53_records can only be true when validation_method is DNS."
  }
}

check "route53_validation_records_require_hosted_zone_id" {
  assert {
    condition     = !var.create_route53_records || var.hosted_zone_id != null
    error_message = "hosted_zone_id is required when create_route53_records is true."
  }
}

check "wait_for_validation_requires_dns_validation_method" {
  assert {
    condition     = !var.wait_for_validation || local.normalized_validation_method == "DNS"
    error_message = "wait_for_validation can only be true when validation_method is DNS."
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = local.normalized_validation_method

  tags = merge(local.common_tags, var.certificate_tags, {
    Name = var.domain_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = local.create_dns_validation_records ? local.domain_validation_options_by_name : {}

  allow_overwrite = true
  zone_id         = var.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = var.validation_record_ttl
  records         = [each.value.value]
}

resource "aws_acm_certificate_validation" "this" {
  count = local.normalized_validation_method == "DNS" && var.wait_for_validation ? 1 : 0

  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = local.create_dns_validation_records ? [
    for record in aws_route53_record.validation :
    record.fqdn
    ] : [
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_name
  ]
}
