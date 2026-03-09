output "certificate_arn" {
  description = "ARN of ACM certificate (validated ARN when wait_for_validation is true)."
  value       = coalesce(try(aws_acm_certificate_validation.this[0].certificate_arn, null), aws_acm_certificate.this.arn)
}

output "certificate_domain_name" {
  description = "Primary domain name configured on ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Current status of ACM certificate."
  value       = aws_acm_certificate.this.status
}

output "validation_method" {
  description = "Validation method configured for ACM certificate."
  value       = aws_acm_certificate.this.validation_method
}

output "domain_validation_options" {
  description = "Domain validation options returned by ACM."
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validation_record_fqdns" {
  description = "Route53 validation record FQDNs created by this module."
  value = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}
