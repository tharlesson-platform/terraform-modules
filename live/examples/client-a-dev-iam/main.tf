locals {
  common_tags = merge(var.tags, {
    Client      = var.client
    Environment = var.environment
    Stack       = "iam"
  })
}

module "workload_roles" {
  source = "../../../modules/iam-workload-roles"

  name_prefix = "${var.client}-${var.environment}"

  workloads                               = var.workload_roles
  default_managed_policy_arns_by_workload = var.default_managed_policy_arns_by_workload
  permissions_boundary_arn                = var.permissions_boundary_arn
  default_max_session_duration            = var.max_session_duration

  tags = local.common_tags
}

output "workload_role_names" {
  value = module.workload_roles.workload_role_names
}

output "workload_role_arns" {
  value = module.workload_roles.workload_role_arns
}

output "terraform_deploy_role_name" {
  value = try(module.workload_roles.workload_role_names["terraform-deploy"], null)
}

output "terraform_deploy_role_arn" {
  value = try(module.workload_roles.workload_role_arns["terraform-deploy"], null)
}
