locals {
  normalized_workloads = {
    for workload_name, workload in var.workloads : workload_name => {
      role_name = coalesce(
        try(workload.role_name, null),
        "${var.name_prefix}-${workload_name}"
      )

      description = coalesce(
        try(workload.description, null),
        "IAM role for ${workload_name} workload."
      )

      trusted_principal_arns = workload.trusted_principal_arns

      managed_policy_arns = (
        try(workload.managed_policy_arns, null) != null
        ? workload.managed_policy_arns
        : lookup(var.default_managed_policy_arns_by_workload, workload_name, [])
      )

      inline_policy_json = try(workload.inline_policy_json, null)
      inline_policy_name = try(workload.inline_policy_name, null)

      permissions_boundary_arn = coalesce(
        try(workload.permissions_boundary_arn, null),
        var.permissions_boundary_arn
      )

      max_session_duration = coalesce(
        try(workload.max_session_duration, null),
        var.default_max_session_duration
      )

      path = coalesce(
        try(workload.path, null),
        var.default_role_path
      )

      enabled = try(workload.enabled, true)
    }
  }

  enabled_workloads = {
    for workload_name, workload in local.normalized_workloads : workload_name => workload
    if workload.enabled
  }
}

module "workload_role" {
  for_each = local.enabled_workloads
  source   = "../iam-role"

  name                     = each.value.role_name
  description              = each.value.description
  path                     = each.value.path
  trusted_principal_arns   = each.value.trusted_principal_arns
  managed_policy_arns      = each.value.managed_policy_arns
  inline_policy_json       = each.value.inline_policy_json
  inline_policy_name       = each.value.inline_policy_name
  permissions_boundary_arn = each.value.permissions_boundary_arn
  max_session_duration     = each.value.max_session_duration

  tags = merge(var.tags, {
    Workload = each.key
  })
}
