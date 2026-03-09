output "load_balancer_id" {
  description = "ID of the ALB."
  value       = aws_lb.this.id
}

output "load_balancer_arn" {
  description = "ARN of the ALB."
  value       = aws_lb.this.arn
}

output "load_balancer_name" {
  description = "Name of the ALB."
  value       = aws_lb.this.name
}

output "load_balancer_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the ALB."
  value       = aws_lb.this.zone_id
}

output "listener_arn" {
  description = "ARN of ALB listener."
  value       = aws_lb_listener.this.arn
}

output "listener_port" {
  description = "Port of ALB listener."
  value       = aws_lb_listener.this.port
}

output "listener_protocol" {
  description = "Protocol of ALB listener."
  value       = aws_lb_listener.this.protocol
}

output "listener_certificate_arn" {
  description = "Certificate ARN configured on HTTPS listener."
  value       = local.resolved_listener_certificate_arn
}

output "target_group_id" {
  description = "ID of created target group, if create_target_group is true."
  value       = try(aws_lb_target_group.this[0].id, null)
}

output "target_group_arn" {
  description = "Resolved target group ARN used by listener."
  value       = local.resolved_target_group_arn
}

output "target_group_name" {
  description = "Name of created target group, if create_target_group is true."
  value       = try(aws_lb_target_group.this[0].name, null)
}

output "target_attachment_ids" {
  description = "Target group attachment IDs keyed by attachment index."
  value = {
    for key, attachment in aws_lb_target_group_attachment.this :
    key => attachment.id
  }
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN created by this module when create_acm_certificate is true."
  value       = try(module.acm[0].certificate_arn, null)
}

output "acm_validation_record_fqdns" {
  description = "Route53 validation record FQDNs created by ACM module."
  value       = try(module.acm[0].validation_record_fqdns, [])
}
