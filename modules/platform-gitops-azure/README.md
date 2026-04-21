# Modulo `platform-gitops-azure`

Modulo opinativo para subir a base Azure usada pelo Nimbus com GitOps:

- `Resource Group`
- `Virtual Network` e subnets para AKS, dados e endpoints privados
- `AKS` com OIDC e Workload Identity
- `Azure Container Registry`
- `Log Analytics`
- `Storage Account` com containers de artefatos e relatórios
- `Azure Key Vault`
- `Azure Database for PostgreSQL Flexible Server`
- identidade dedicada ao `External Secrets Operator`

## Uso esperado

O stack consumidor aplica este modulo primeiro e depois faz o bootstrap do Argo CD/Ingress/External Secrets usando a conectividade do cluster e a identidade exportada para o ESO.

## Saídas principais

- `cluster_name`
- `cluster_host`
- `cluster_ca_certificate`
- `acr_login_server`
- `key_vault_uri`
- `external_secrets_identity_client_id`
- `postgresql_connection_string`
