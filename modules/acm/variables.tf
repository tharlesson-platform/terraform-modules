variable "domain_name" {
  description = "Primary domain name for ACM certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Optional SAN entries for ACM certificate."
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Validation method used by ACM certificate (DNS or EMAIL)."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], upper(var.validation_method))
    error_message = "validation_method must be DNS or EMAIL."
  }
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID used for automatic DNS validation records."
  type        = string
  default     = null
}

variable "create_route53_records" {
  description = "Whether to create Route53 DNS validation records automatically."
  type        = bool
  default     = true
}

variable "validation_record_ttl" {
  description = "TTL in seconds for Route53 validation records."
  type        = number
  default     = 60

  validation {
    condition     = var.validation_record_ttl >= 1 && var.validation_record_ttl <= 172800
    error_message = "validation_record_ttl must be between 1 and 172800."
  }
}

variable "wait_for_validation" {
  description = "Whether Terraform should wait for ACM certificate DNS validation."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "certificate_tags" {
  description = "Additional tags applied only to ACM certificate resource."
  type        = map(string)
  default     = {}
}
