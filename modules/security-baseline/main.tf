data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  cloudtrail_name = coalesce(var.cloudtrail_name, "${var.name_prefix}-cloudtrail")
  cloudtrail_arn  = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"

  kms_alias_name = coalesce(var.kms_alias_name, "alias/${var.name_prefix}-security-baseline")

  config_role_name             = coalesce(var.config_role_name, "${var.name_prefix}-config-role")
  config_recorder_name         = coalesce(var.config_recorder_name, "${var.name_prefix}-config-recorder")
  config_delivery_channel_name = coalesce(var.config_delivery_channel_name, "${var.name_prefix}-config-delivery")

  cloudtrail_s3_prefix = trim(var.cloudtrail_s3_key_prefix, "/")
  config_s3_prefix     = trim(var.config_s3_key_prefix, "/")

  cloudtrail_log_object_prefix = local.cloudtrail_s3_prefix == "" ? "AWSLogs/${data.aws_caller_identity.current.account_id}/*" : "${local.cloudtrail_s3_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
  config_log_object_prefix     = local.config_s3_prefix == "" ? "AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*" : "${local.config_s3_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "security-baseline"
  })
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRootAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudTrailUsage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowConfigUsage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "this" {
  description             = "KMS key for CloudTrail and AWS Config logs (${var.name_prefix})."
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.enable_kms_key_rotation
  policy                  = data.aws_iam_policy_document.kms.json

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-security-baseline"
  })
}

resource "aws_kms_alias" "this" {
  name          = local.kms_alias_name
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_s3_bucket" "audit" {
  bucket        = var.audit_bucket_name
  force_destroy = var.force_destroy_bucket

  tags = merge(local.common_tags, {
    Name = var.audit_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    id     = "expire-old-audit-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.log_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.log_expiration_days
    }
  }
}

data "aws_iam_policy_document" "audit_bucket" {
  statement {
    sid = "CloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.audit.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement {
    sid = "CloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.audit.arn}/${local.cloudtrail_log_object_prefix}"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement {
    sid = "ConfigAclCheck"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.audit.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid = "ConfigWrite"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.audit.arn}/${local.config_log_object_prefix}"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id
  policy = data.aws_iam_policy_document.audit_bucket.json
}

resource "aws_cloudtrail" "this" {
  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.audit.id
  s3_key_prefix                 = local.cloudtrail_s3_prefix == "" ? null : local.cloudtrail_s3_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_cloudtrail
  kms_key_id                    = aws_kms_key.this.arn

  event_selector {
    include_management_events = true
    read_write_type           = var.cloudtrail_management_events_read_write_type
  }

  depends_on = [aws_s3_bucket_policy.audit]

  tags = merge(local.common_tags, {
    Name = local.cloudtrail_name
  })
}

data "aws_iam_policy_document" "config_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = local.config_role_name
  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json

  tags = merge(local.common_tags, {
    Name = local.config_role_name
  })
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "config_delivery" {
  statement {
    sid = "AllowAuditBucketListing"

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.audit.arn]
  }

  statement {
    sid     = "AllowConfigObjectWrite"
    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.audit.arn}/${local.config_log_object_prefix}"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AllowKmsUsage"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = [aws_kms_key.this.arn]
  }
}

resource "aws_iam_role_policy" "config_delivery" {
  name   = "${local.config_role_name}-delivery"
  role   = aws_iam_role.config.id
  policy = data.aws_iam_policy_document.config_delivery.json
}

resource "aws_config_configuration_recorder" "this" {
  name     = local.config_recorder_name
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.config_include_global_resource_types
  }

  depends_on = [
    aws_iam_role_policy_attachment.config_managed,
    aws_iam_role_policy.config_delivery
  ]
}

resource "aws_config_delivery_channel" "this" {
  name           = local.config_delivery_channel_name
  s3_bucket_name = aws_s3_bucket.audit.id
  s3_key_prefix  = local.config_s3_prefix == "" ? null : local.config_s3_prefix

  snapshot_delivery_properties {
    delivery_frequency = var.config_snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}
