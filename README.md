# Terraform AWS Platform Blueprint

Este repositorio apresenta um blueprint Terraform para operacao multi-conta e multi-ambiente em AWS.
A proposta e separar infraestrutura em modulos reutilizaveis e stacks de ambiente, com exemplos prontos para onboarding rapido.

## Executive Summary

O projeto implementa uma base de plataforma com:
- Rede (VPC) com subnets por tier, NAT e endpoints.
- Dados (RDS) com seguranca e parametros operacionais.
- Compute (EC2) com bootstrap, IAM profile e opcional de EIP.
- Compute elastico (EC2 Auto Scaling) com launch template e politicas de escala.
- IAM para workloads por meio de roles padronizadas.
- Security baseline com KMS, CloudTrail e AWS Config.
- Storage (S3) com guardrails de seguranca e lifecycle.

Essa estrutura permite evolucao progressiva: comecar por um exemplo, promover para dev, depois stg e prod com mudanca controlada de terraform.tfvars e backend.

## Architecture

### 1) Modulos (modules/)
Camada de composicao tecnica. Cada modulo encapsula um dominio de infraestrutura:
- vpc
- rds
- ec2
- ec2-autoscaling
- iam-role
- iam-workload-roles
- security-baseline
- s3

### 2) Stacks (live/client-a/<env>/<stack>)
Camada de implementacao por ambiente:
- Ambientes: dev, stg, prod
- Stacks: vpc, rds, ec2, ec2-autoscaling, iam, security-baseline, s3

### 3) Examples (live/examples/)
Referencias executaveis para client-a-dev-* em todos os stacks.
Sao o caminho mais rapido para clonar um novo cliente/ambiente.

## Catalogo de Modulos

| Modulo | Objetivo | Consumido por stacks |
|---|---|---|
| vpc | Rede base com subnets public/private/database, NAT e endpoints | vpc |
| rds | Banco relacional gerenciado com controles de seguranca e operacao | rds |
| ec2 | Instancias EC2 com networking, SG, IAM profile e bootstrap | ec2 |
| ec2-autoscaling | Grupo de Auto Scaling para EC2 com launch template e politicas de escala | ec2-autoscaling |
| iam-role | Modulo base para criacao de uma IAM role | Interno/consumido por iam-workload-roles |
| iam-workload-roles | Orquestra multiplas IAM roles por workload | iam |
| security-baseline | KMS + CloudTrail + AWS Config + bucket de auditoria | security-baseline |
| s3 | Bucket S3 com controles de seguranca e configuracoes operacionais | s3 |

## Mapa de Stacks por Ambiente

| Ambiente | VPC | RDS | EC2 | EC2 Auto Scaling | IAM | Security Baseline | S3 |
|---|---|---|---|---|---|---|---|
| dev | live/client-a/dev/vpc | live/client-a/dev/rds | live/client-a/dev/ec2 | live/client-a/dev/ec2-autoscaling | live/client-a/dev/iam | live/client-a/dev/security-baseline | live/client-a/dev/s3 |
| stg | live/client-a/stg/vpc | live/client-a/stg/rds | live/client-a/stg/ec2 | live/client-a/stg/ec2-autoscaling | live/client-a/stg/iam | live/client-a/stg/security-baseline | live/client-a/stg/s3 |
| prod | live/client-a/prod/vpc | live/client-a/prod/rds | live/client-a/prod/ec2 | live/client-a/prod/ec2-autoscaling | live/client-a/prod/iam | live/client-a/prod/security-baseline | live/client-a/prod/s3 |

## Ordem Recomendada de Provisionamento

1. security-baseline
2. iam
3. vpc
4. s3
5. rds
6. ec2
7. ec2-autoscaling

Observacao: rds, ec2 e ec2-autoscaling normalmente consomem informacoes da vpc.

## Como Executar um Stack

```bash
cd live/client-a/<env>/<stack>
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

## Convencoes Operacionais

- Tagging padrao por stack via locals.common_tags.
- Configuracao por ambiente em terraform.tfvars.
- Provider com suporte a profile e assume_role.
- Backend remoto parametrizado por backend.hcl.
- backend.hcl e .terraform/ ignorados por git para evitar vazamento de contexto local.

## Estrategia para Novos Clientes

1. Copiar stack de live/examples/client-a-dev-<stack>.
2. Renomear caminhos para o novo cliente/ambiente.
3. Ajustar terraform.tfvars.
4. Ajustar backend.hcl (bucket/key/table).
5. Executar init, plan, apply.

## Documentacao Local

Cada modulo, stack e example possui README proprio com:
- escopo tecnico,
- dependencias,
- arquivos-chave,
- instrucoes de operacao.

Isso torna o repositorio autoexplicativo para onboarding, revisao tecnica e publicacao.
