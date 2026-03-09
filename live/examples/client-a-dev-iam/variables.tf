variable "region" {
  description = "AWS region."
  type        = string
}

variable "aws_profile" {
  description = "Optional AWS CLI profile."
  type        = string
  default     = null
}

variable "aws_assume_role_arn" {
  description = "Optional IAM Role ARN to assume in target AWS account."
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name used when assuming role."
  type        = string
  default     = "terraform-iam-bootstrap"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "workload_roles" {
  description = "IAM role definitions keyed by workload name."
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
}

variable "default_managed_policy_arns_by_workload" {
  description = "Fallback managed policy ARNs per workload when not explicitly set in workload_roles."
  type        = map(list(string))
  default     = {}
}

variable "permissions_boundary_arn" {
  description = "Optional IAM permissions boundary ARN applied to workload roles by default."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Default maximum role session duration in seconds when not set per workload."
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

