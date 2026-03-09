variable "name_prefix" {
  description = "Prefix used to build IAM role names when role_name is not explicitly defined."
  type        = string
}

variable "workloads" {
  description = "Map of IAM workload definitions keyed by workload name."
  type = map(object({
    trusted_principal_arns   = list(string)
    role_name                = optional(string)
    description              = optional(string)
    managed_policy_arns      = optional(list(string))
    inline_policy_json       = optional(string)
    inline_policy_name       = optional(string)
    permissions_boundary_arn = optional(string)
    max_session_duration     = optional(number)
    path                     = optional(string)
    enabled                  = optional(bool)
  }))

  validation {
    condition = alltrue([
      for workload in values(var.workloads) : length(workload.trusted_principal_arns) > 0
    ])
    error_message = "Every workload must define at least one trusted principal ARN."
  }

  validation {
    condition = alltrue([
      for workload in values(var.workloads) : (
        try(workload.inline_policy_json, null) == null || can(jsondecode(workload.inline_policy_json))
      )
    ])
    error_message = "inline_policy_json must be valid JSON for each workload when provided."
  }
}

variable "default_managed_policy_arns_by_workload" {
  description = "Default managed policy ARNs used when a workload does not define managed_policy_arns."
  type        = map(list(string))
  default     = {}
}

variable "permissions_boundary_arn" {
  description = "Optional default permissions boundary ARN applied to workload roles."
  type        = string
  default     = null
}

variable "default_max_session_duration" {
  description = "Default maximum role session duration in seconds when not set per workload."
  type        = number
  default     = 3600

  validation {
    condition     = var.default_max_session_duration >= 3600 && var.default_max_session_duration <= 43200
    error_message = "default_max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "default_role_path" {
  description = "Default IAM role path when not set per workload."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.default_role_path, "/") && endswith(var.default_role_path, "/")
    error_message = "default_role_path must start and end with '/'."
  }
}

variable "tags" {
  description = "Common tags applied to all workload roles."
  type        = map(string)
  default     = {}
}
