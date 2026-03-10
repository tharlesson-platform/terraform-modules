output "cluster_arn" {
  description = "ARN of EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_name" {
  description = "Name of EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint URL of EKS cluster API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL from EKS cluster identity."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN created for EKS cluster when enabled."
  value       = try(aws_iam_openid_connect_provider.this[0].arn, null)
}

output "control_plane_role_arn" {
  description = "Resolved IAM role ARN used by EKS control plane."
  value       = local.resolved_cluster_role_arn
}

output "node_role_arn" {
  description = "Resolved IAM role ARN used by EKS managed node groups."
  value       = local.resolved_node_role_arn
}

output "control_plane_security_group_id" {
  description = "Resolved security group ID attached to EKS control plane."
  value       = local.resolved_cluster_security_group_id
}

output "node_security_group_ids" {
  description = "Resolved security group IDs attached to EKS worker nodes."
  value       = local.resolved_node_security_group_ids
}

output "node_group_arns" {
  description = "ARNs of created EKS managed node groups keyed by node group name."
  value = {
    for name, node_group in aws_eks_node_group.this :
    name => node_group.arn
  }
}

output "node_group_status" {
  description = "Status of created EKS managed node groups keyed by node group name."
  value = {
    for name, node_group in aws_eks_node_group.this :
    name => node_group.status
  }
}

output "cloudwatch_log_group_name" {
  description = "Resolved CloudWatch log group name used by EKS control plane logs."
  value       = local.discovered_log_group_name
}

output "ingress_alb_load_balancer_arn" {
  description = "ALB ARN created by this module when create_alb is true."
  value       = try(module.alb[0].load_balancer_arn, null)
}

output "ingress_alb_load_balancer_dns_name" {
  description = "ALB DNS name created by this module when create_alb is true."
  value       = try(module.alb[0].load_balancer_dns_name, null)
}

output "ingress_alb_listener_arn" {
  description = "ALB listener ARN created by this module when create_alb is true."
  value       = try(module.alb[0].listener_arn, null)
}

output "ingress_target_group_arn" {
  description = "Resolved ALB target group ARN used for EKS ingress traffic."
  value       = local.resolved_ingress_target_group_arn
}

output "ingress_alb_acm_certificate_arn" {
  description = "ACM certificate ARN created through ALB module when enabled."
  value       = try(module.alb[0].acm_certificate_arn, null)
}
