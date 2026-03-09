# Module: IAM Workload Roles

## Purpose
Orquestra a criacao padronizada de multiplas IAM roles por workload usando um mapa declarativo.

## What This Module Builds
- N IAM roles a partir de workloads.
- Attach de managed policies por workload.
- Inline policy opcional por workload.
- Defaults globais para sessao, path e boundary.

## Key Inputs
- name_prefix
- workloads
- default_managed_policy_arns_by_workload
- permissions_boundary_arn
- default_max_session_duration

## Key Outputs
- enabled_workloads
- workload_role_names
- workload_role_arns
- workload_role_unique_ids

## Where It Is Used
- live/client-a/*/iam
- live/examples/client-a-dev-iam

## Notes
Padronizar nomes de workloads entre ambientes simplifica auditoria e automacao.