# Modulo `ecr`

Provisiona um ou mais repositórios Amazon ECR com scan on push e política simples de retenção.

## Entradas principais

- `repositories`: nomes dos repositórios
- `force_delete`: permite destruir repositórios com imagens
- `tags`: tags comuns

## Saídas principais

- `repository_urls`
- `repository_arns`
