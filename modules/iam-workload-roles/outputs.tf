output "enabled_workloads" {
  description = "Enabled workload names."
  value       = sort(keys(local.enabled_workloads))
}

output "workload_role_names" {
  description = "Role names keyed by workload."
  value = {
    for workload_name, role in module.workload_role : workload_name => role.role_name
  }
}

output "workload_role_arns" {
  description = "Role ARNs keyed by workload."
  value = {
    for workload_name, role in module.workload_role : workload_name => role.role_arn
  }
}

output "workload_role_unique_ids" {
  description = "Role unique IDs keyed by workload."
  value = {
    for workload_name, role in module.workload_role : workload_name => role.role_unique_id
  }
}
