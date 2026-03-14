# Terraform AWS Platform Blueprint

Este repositorio apresenta um blueprint Terraform pronto para operacao multi-conta e multi-ambiente em AWS.
A proposta e separar infraestrutura em modulos reutilizaveis e stacks de ambiente, com exemplos prontos (client-a-dev) para onboarding rapido.

## Executive Summary

O projeto implementa uma base de plataforma com:
- Rede (VPC) com subnets por tier, NAT e endpoints.
- Dados (RDS) com seguranca e parametros operacionais.
- Compute (EC2) com bootstrap, IAM profile e opcional de EIP.
- Compute elastico (EC2 Auto Scaling) com launch template e politicas de escala.
- Compute containerizado (ECS) com service, task definition, autoscaling e integracao com ALB/ACM.
- Compute Kubernetes (EKS) com cluster gerenciado, node groups, OIDC e integracao com ALB/ACM.
- Balanceamento de carga com modulos de ELB classico e ALB com target groups e health check.
- IAM para workloads por meio de roles padronizadas.
- Security baseline com KMS, CloudTrail e AWS Config.
- Storage (S3) com guardrails de seguranca e lifecycle.

Essa estrutura permite evolucao progressiva: comecar por um exemplo, promover para dev, depois stg e prod com mudanca controlada de terraform.tfvars e backend.

## Architecture

### 1) Modulos (modules/)
Camada de composicao tecnica. Cada modulo encapsula um dominio de infraestrutura:
- vpc
- acm
- alb
- elb
- eks
- rds
- ec2
- ec2-autoscaling
- ecs
- iam-role
- iam-workload-roles
- security-baseline
- s3

### 2) Stacks (live/client-a/<env>/<stack>)
Camada de implementacao por ambiente:
- Ambientes: dev, stg, prod
- Stacks: vpc, rds, ec2, ec2-autoscaling, ecs, eks, iam, security-baseline, s3

### 3) Examples (live/examples/)
Referencias executaveis para client-a-dev-* em todos os stacks do baseline.
No estado atual, os examples sao somente dev; stg/prod sao promovidos a partir desses exemplos com ajuste de terraform.tfvars e backend.

## Catalogo de Modulos

| Modulo | Objetivo | Consumido por stacks |
|---|---|---|
| vpc | Rede base com subnets public/private/database, NAT e endpoints | vpc |
| acm | Certificados TLS com validacao DNS/EMAIL e Route53 opcional | Consumido por `alb` (direto ou via composicoes em `ecs`/`eks`) |
| alb | Application Load Balancer com listener, target group e health check | Consumido por composicoes em `ecs`/`eks` ou por stacks custom |
| elb | Classic ELB com listeners e health check | Modulo disponivel para stacks legados/custom |
| eks | EKS com cluster, node groups, IAM, OIDC e composicao opcional de ALB/ACM | eks |
| rds | Banco relacional gerenciado com controles de seguranca e operacao | rds |
| ec2 | Instancias EC2 com networking, SG, IAM profile e bootstrap | ec2 |
| ec2-autoscaling | Grupo de Auto Scaling para EC2 com launch template e politicas de escala | ec2-autoscaling |
| ecs | ECS com service, task definition, autoscaling e composicao opcional de ALB/ACM | ecs |
| iam-role | Modulo base para criacao de uma IAM role | Interno/consumido por iam-workload-roles |
| iam-workload-roles | Orquestra multiplas IAM roles por workload | iam |
| security-baseline | KMS + CloudTrail + AWS Config + bucket de auditoria | security-baseline |
| s3 | Bucket S3 com controles de seguranca e configuracoes operacionais | s3 |

## Mapa de Stacks por Ambiente

| Ambiente | VPC | RDS | EC2 | EC2 Auto Scaling | ECS | EKS | IAM | Security Baseline | S3 |
|---|---|---|---|---|---|---|---|---|---|
| dev | live/client-a/dev/vpc | live/client-a/dev/rds | live/client-a/dev/ec2 | live/client-a/dev/ec2-autoscaling | live/client-a/dev/ecs | live/client-a/dev/eks | live/client-a/dev/iam | live/client-a/dev/security-baseline | live/client-a/dev/s3 |
| stg | live/client-a/stg/vpc | live/client-a/stg/rds | live/client-a/stg/ec2 | live/client-a/stg/ec2-autoscaling | live/client-a/stg/ecs | live/client-a/stg/eks | live/client-a/stg/iam | live/client-a/stg/security-baseline | live/client-a/stg/s3 |
| prod | live/client-a/prod/vpc | live/client-a/prod/rds | live/client-a/prod/ec2 | live/client-a/prod/ec2-autoscaling | live/client-a/prod/ecs | live/client-a/prod/eks | live/client-a/prod/iam | live/client-a/prod/security-baseline | live/client-a/prod/s3 |

## Ordem Recomendada de Provisionamento

1. security-baseline
2. iam
3. vpc
4. acm (quando aplicavel em composicoes ou stack custom)
5. alb/elb (quando aplicavel em composicoes ou stack custom)
6. s3
7. rds
8. ecs
9. eks
10. ec2
11. ec2-autoscaling

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
- Provider com suporte a profile e assume_role (pronto para uso multi-conta por stack/ambiente).
- Backend remoto parametrizado por backend.hcl (S3).
- State locking via lock file no S3 (`use_lockfile = true`, arquivo `.tflock`).
- backend.hcl e .terraform/ ignorados por git para evitar vazamento de contexto local.

## Estrategia para Novos Clientes

1. Copiar stack de live/examples/client-a-dev-<stack>.
2. Renomear caminhos para o novo cliente/ambiente.
3. Ajustar terraform.tfvars.
4. Ajustar backend.hcl (bucket/key/region).
5. Executar init, plan, apply.

## Documentacao Local

Cada modulo, stack e example possui README proprio com:
- escopo tecnico,
- dependencias,
- arquivos-chave,
- instrucoes de operacao.

Isso torna o repositorio autoexplicativo para onboarding, revisao tecnica e publicacao.

## Licenca
Este projeto esta licenciado sob a Apache License 2.0. Consulte o arquivo `LICENSE` para mais detalhes.

## Atribuicao
Este projeto foi desenvolvido e publicado por **Tharlesson**.
Caso voce utilize este material como base em ambientes internos, estudos, adaptacoes ou redistribuicoes, preserve os creditos de autoria e os avisos de licenca aplicaveis.

## Creditos e Uso
Este repositorio foi criado com foco em automacao, padronizacao operacional e melhoria da rotina de profissionais de SRE, DevOps, Cloud e Plataforma.

Voce pode:
- estudar
- reutilizar
- adaptar
- evoluir este projeto dentro do seu contexto

Ao reutilizar ou derivar este material:
- mantenha os avisos de licenca
- preserve os creditos de autoria quando aplicavel
- documente alteracoes relevantes feitas sobre a base original

## Autor
**Tharlesson**  
GitHub: https://github.com/tharlesson
