# Module: VPC

## Purpose
Cria a fundacao de networking AWS para workloads de aplicacao e dados.

## What This Module Builds
- VPC com DNS support/hostnames.
- Subnets public, private e database por AZ.
- Internet Gateway e NAT Gateway (single ou por AZ).
- Route tables por tier.
- DB subnet group opcional.
- Gateway endpoints (S3/DynamoDB) opcionais.
- Flow logs opcionais para CloudWatch.
- Gerenciamento opcional do default security group.

## Key Inputs
- name, cidr_block, azs
- public_subnet_cidrs, private_subnet_cidrs, database_subnet_cidrs
- enable_nat_gateway, single_nat_gateway, one_nat_gateway_per_az
- create_database_subnet_group
- enable_s3_gateway_endpoint, enable_dynamodb_gateway_endpoint
- enable_flow_logs

## Key Outputs
- vpc_id, vpc_arn, vpc_cidr_block
- public_subnet_ids, private_subnet_ids, database_subnet_ids
- database_subnet_group_name
- nat_gateway_ids, nat_public_ips

## Where It Is Used
- live/client-a/*/vpc
- live/examples/client-a-dev-vpc

## Notes
Use este modulo primeiro no ciclo de provisionamento, pois stacks como rds e ec2 dependem de artefatos de rede.