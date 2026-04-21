output "repository_urls" {
  description = "ECR repository URLs keyed by repository name."
  value = {
    for repository_name, repository in aws_ecr_repository.this :
    repository_name => repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs keyed by repository name."
  value = {
    for repository_name, repository in aws_ecr_repository.this :
    repository_name => repository.arn
  }
}
