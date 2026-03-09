variable "name" {
  description = "IAM role name."
  type        = string
}

variable "description" {
  description = "IAM role description."
  type        = string
  default     = "Managed by Terraform for deployment automation."
}

variable "path" {
  description = "IAM role path."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.path, "/") && endswith(var.path, "/")
    error_message = "path must start and end with '/'."
  }
}

variable "trusted_principal_arns" {
  description = "IAM principal ARNs allowed to assume this role."
  type        = list(string)
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs attached to the role."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

variable "inline_policy_json" {
  description = "Optional inline policy JSON attached to the role."
  type        = string
  default     = null

  validation {
    condition     = var.inline_policy_json == null || can(jsondecode(var.inline_policy_json))
    error_message = "inline_policy_json must be valid JSON when provided."
  }
}

variable "inline_policy_name" {
  description = "Optional inline policy name. Defaults to <name>-inline."
  type        = string
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Optional IAM permissions boundary ARN."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum role session duration in seconds."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "force_detach_policies" {
  description = "Detach all managed policies from the role before role deletion."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
