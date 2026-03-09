check "trusted_principals_not_empty" {
  assert {
    condition     = length(var.trusted_principal_arns) > 0
    error_message = "trusted_principal_arns must contain at least one IAM principal ARN."
  }
}

check "inline_policy_name_requires_inline_policy_json" {
  assert {
    condition     = var.inline_policy_json != null || var.inline_policy_name == null
    error_message = "inline_policy_name can only be set when inline_policy_json is provided."
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowTrustedPrincipals"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_principal_arns
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = var.name
  description           = var.description
  path                  = var.path
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = merge(var.tags, {
    Name      = var.name
    ManagedBy = "Terraform"
    Module    = "iam-role"
  })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy_json == null ? 0 : 1

  name   = coalesce(var.inline_policy_name, "${var.name}-inline")
  role   = aws_iam_role.this.name
  policy = var.inline_policy_json
}
