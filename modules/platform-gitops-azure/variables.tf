variable "name" {
  description = "Base name used to derive Azure resources for the GitOps platform."
  type        = string
}

variable "location" {
  description = "Azure region used by the platform."
  type        = string
}

variable "resource_group_name" {
  description = "Optional explicit resource group name."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Optional explicit AKS cluster name."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "Optional AKS DNS prefix."
  type        = string
  default     = null
}

variable "vnet_cidr" {
  description = "CIDR used by the platform virtual network."
  type        = string
}

variable "aks_subnet_cidr" {
  description = "CIDR allocated to AKS node pools."
  type        = string
}

variable "private_endpoints_subnet_cidr" {
  description = "CIDR reserved for private endpoints and future data-plane integrations."
  type        = string
}

variable "database_subnet_cidr" {
  description = "CIDR delegated to Azure Database for PostgreSQL Flexible Server."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = "1.31.6"
}

variable "aks_sku_tier" {
  description = "AKS SKU tier."
  type        = string
  default     = "Standard"
}

variable "node_vm_size" {
  description = "VM size used by the default AKS node pool."
  type        = string
  default     = "Standard_D4as_v5"
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling for the default AKS node pool."
  type        = bool
  default     = true
}

variable "node_count" {
  description = "Default node count when autoscaling is disabled."
  type        = number
  default     = 2
}

variable "node_min_count" {
  description = "Minimum node count when autoscaling is enabled."
  type        = number
  default     = 2
}

variable "node_max_count" {
  description = "Maximum node count when autoscaling is enabled."
  type        = number
  default     = 6
}

variable "log_analytics_sku" {
  description = "SKU used by the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Retention of logs sent to Log Analytics."
  type        = number
  default     = 30
}

variable "acr_sku" {
  description = "SKU used by the Azure Container Registry."
  type        = string
  default     = "Premium"
}

variable "storage_account_tier" {
  description = "Tier used by the Azure Storage Account."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication strategy used by the Azure Storage Account."
  type        = string
  default     = "LRS"
}

variable "key_vault_sku_name" {
  description = "SKU used by Azure Key Vault."
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection on Azure Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft-delete retention for Azure Key Vault."
  type        = number
  default     = 30
}

variable "external_secrets_namespace" {
  description = "Namespace where External Secrets Operator will run."
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account_name" {
  description = "Service account used by External Secrets Operator."
  type        = string
  default     = "external-secrets"
}

variable "postgresql_version" {
  description = "Azure Database for PostgreSQL Flexible Server version."
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "SKU used by PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D2ds_v5"
}

variable "postgresql_storage_mb" {
  description = "Allocated storage in MB for PostgreSQL Flexible Server."
  type        = number
  default     = 32768
}

variable "postgresql_zone" {
  description = "Availability zone used by PostgreSQL Flexible Server."
  type        = string
  default     = "1"
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention in days for PostgreSQL Flexible Server."
  type        = number
  default     = 7
}

variable "postgresql_geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups for PostgreSQL Flexible Server."
  type        = bool
  default     = false
}

variable "postgresql_administrator_login" {
  description = "Admin username used by PostgreSQL Flexible Server."
  type        = string
  default     = "nimbusadmin"
}

variable "postgresql_administrator_password" {
  description = "Admin password used by PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
}

variable "postgresql_database_name" {
  description = "Application database created inside PostgreSQL Flexible Server."
  type        = string
  default     = "nimbus"
}

variable "tags" {
  description = "Common tags applied to all created resources."
  type        = map(string)
  default     = {}
}
