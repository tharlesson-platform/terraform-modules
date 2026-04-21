variable "repositories" {
  description = "List of ECR repositories to create."
  type        = list(string)
}

variable "force_delete" {
  description = "Allow deleting repositories that still contain images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to created repositories."
  type        = map(string)
  default     = {}
}
