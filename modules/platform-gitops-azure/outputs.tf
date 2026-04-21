output "resource_group_name" {
  description = "Resource group used by the Azure GitOps platform."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region used by the platform."
  value       = azurerm_resource_group.this.location
}

output "vnet_id" {
  description = "Virtual network ID used by the platform."
  value       = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  description = "Subnet ID used by AKS nodes."
  value       = azurerm_subnet.aks.id
}

output "database_subnet_id" {
  description = "Delegated subnet ID used by PostgreSQL Flexible Server."
  value       = azurerm_subnet.database.id
}

output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_host" {
  description = "AKS API server host."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "cluster_client_certificate" {
  description = "Client certificate returned by AKS kube_config."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "cluster_client_key" {
  description = "Client key returned by AKS kube_config."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate returned by AKS kube_config."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL exposed by AKS."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "acr_id" {
  description = "Azure Container Registry resource ID."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.this.login_server
}

output "storage_account_name" {
  description = "Storage account name used by the platform."
  value       = azurerm_storage_account.this.name
}

output "application_container_name" {
  description = "Storage container name reserved for application artifacts."
  value       = azurerm_storage_container.app_artifacts.name
}

output "reports_container_name" {
  description = "Storage container name reserved for report artifacts."
  value       = azurerm_storage_container.reports.name
}

output "key_vault_id" {
  description = "Key Vault resource ID."
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.this.vault_uri
}

output "external_secrets_identity_id" {
  description = "User-assigned identity ID dedicated to External Secrets Operator."
  value       = azurerm_user_assigned_identity.external_secrets.id
}

output "external_secrets_identity_client_id" {
  description = "Client ID of the identity used by External Secrets Operator."
  value       = azurerm_user_assigned_identity.external_secrets.client_id
}

output "external_secrets_identity_principal_id" {
  description = "Principal ID of the identity used by External Secrets Operator."
  value       = azurerm_user_assigned_identity.external_secrets.principal_id
}

output "postgresql_server_name" {
  description = "PostgreSQL Flexible Server name."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgresql_database_name" {
  description = "Application database created in PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "postgresql_connection_string" {
  description = "Connection string used by Nimbus to connect to PostgreSQL on Azure."
  value       = "postgresql://${var.postgresql_administrator_login}:${var.postgresql_administrator_password}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${azurerm_postgresql_flexible_server_database.this.name}"
  sensitive   = true
}
