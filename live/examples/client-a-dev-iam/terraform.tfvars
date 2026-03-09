region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-iam-client-a-dev"

client      = "client-a"
environment = "dev"

workload_roles = {
  terraform-deploy = {
    role_name   = "terraform-deploy"
    description = "Cross-account role used by Terraform deploy pipelines."
    trusted_principal_arns = [
      "arn:aws:iam::111122223333:role/platform-terraform"
    ]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess"
    ]
  }

  app-runtime = {
    role_name   = "app-runtime"
    description = "Role assumed by application runtime workloads (EC2/ECS/EKS)."
    trusted_principal_arns = [
      "arn:aws:iam::111122223333:role/client-a-dev-ecs-tasks"
    ]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  batch-jobs = {
    role_name   = "batch-jobs"
    description = "Role used by batch and scheduled job workloads."
    trusted_principal_arns = [
      "arn:aws:iam::111122223333:role/client-a-dev-batch-service"
    ]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ]
  }

  ci-cd = {
    role_name   = "ci-cd"
    description = "Role used by CI/CD automation runners."
    trusted_principal_arns = [
      "arn:aws:iam::111122223333:role/client-a-dev-ci-runner"
    ]
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/PowerUserAccess"
    ]
  }
}

default_managed_policy_arns_by_workload = {}
permissions_boundary_arn                = null
max_session_duration                    = 3600

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}
