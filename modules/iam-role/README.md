# Module: IAM Role

## Purpose
Modulo base para criacao de IAM roles unitarias com trust policy e attach de policies.

## What This Module Builds
- aws_iam_role
- aws_iam_role_policy_attachment (0..N)
- Inline policy opcional

## Key Inputs
- name, description, path
- trusted_principal_arns
- managed_policy_arns
- inline_policy_json
- permissions_boundary_arn

## Key Outputs
- role_name, role_arn, role_unique_id

## Where It Is Used
- Consumido pelo modulo iam-workload-roles
- Disponivel para composicoes customizadas

## Notes
Mantenha trust policy minima e policy attachments em menor privilegio.