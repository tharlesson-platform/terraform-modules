locals {
  load_balancer_name = coalesce(var.load_balancer_name, "${var.name}-alb")
  target_group_name  = coalesce(var.target_group_name, "${var.name}-tg")

  resolved_target_group_arn = coalesce(try(aws_lb_target_group.this[0].arn, null), var.target_group_arn)
  resolved_listener_certificate_arn = coalesce(
    try(module.acm[0].certificate_arn, null),
    var.listener_certificate_arn
  )

  target_attachments = {
    for index, attachment in var.target_attachments :
    tostring(index) => attachment
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "alb"
    Workload  = var.name
  })
}

check "acm_domain_name_is_required_when_create_acm_certificate_is_enabled" {
  assert {
    condition     = !var.create_acm_certificate || var.acm_domain_name != null
    error_message = "acm_domain_name is required when create_acm_certificate is true."
  }
}

check "acm_creation_and_explicit_listener_certificate_are_mutually_exclusive" {
  assert {
    condition     = !(var.create_acm_certificate && var.listener_certificate_arn != null)
    error_message = "Use create_acm_certificate or listener_certificate_arn, but not both."
  }
}

check "subnet_count_is_valid" {
  assert {
    condition     = length(var.subnet_ids) >= 2
    error_message = "For ALB, provide at least two subnet IDs."
  }
}

check "security_groups_are_provided" {
  assert {
    condition     = length(var.security_group_ids) > 0
    error_message = "Provide at least one security group ID for ALB."
  }
}

check "target_group_inputs_are_consistent" {
  assert {
    condition = var.create_target_group ? (
      var.vpc_id != null && var.target_group_arn == null
      ) : (
      true
    )
    error_message = "When create_target_group is true, set vpc_id and keep target_group_arn as null."
  }
}

check "forward_action_target_group_is_resolvable" {
  assert {
    condition     = var.listener_default_action_type != "forward" || local.resolved_target_group_arn != null
    error_message = "Forward listener action requires create_target_group=true or target_group_arn set."
  }
}

check "https_listener_requires_certificate" {
  assert {
    condition     = upper(var.listener_protocol) != "HTTPS" || local.resolved_listener_certificate_arn != null
    error_message = "HTTPS listener requires a certificate ARN from listener_certificate_arn or ACM module."
  }
}

check "target_attachments_require_target_group" {
  assert {
    condition     = length(var.target_attachments) == 0 || local.resolved_target_group_arn != null
    error_message = "target_attachments require a resolved target group ARN."
  }
}

check "health_check_timeout_is_less_than_interval" {
  assert {
    condition     = var.health_check_timeout < var.health_check_interval
    error_message = "health_check_timeout must be lower than health_check_interval."
  }
}

resource "aws_lb" "this" {
  name                       = local.load_balancer_name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  drop_invalid_header_fields = var.drop_invalid_header_fields
  idle_timeout               = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]
    content {
      bucket  = access_logs.value.bucket
      enabled = try(access_logs.value.enabled, true)
      prefix  = try(access_logs.value.prefix, null)
    }
  }

  tags = merge(local.common_tags, var.load_balancer_tags, {
    Name = local.load_balancer_name
  })
}

resource "aws_lb_target_group" "this" {
  count = var.create_target_group ? 1 : 0

  name                 = local.target_group_name
  port                 = var.target_group_port
  protocol             = upper(var.target_group_protocol)
  protocol_version     = var.protocol_version
  target_type          = var.target_type
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = upper(coalesce(var.health_check_protocol, var.target_group_protocol))
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
      type            = var.stickiness_type
    }
  }

  tags = merge(local.common_tags, var.target_group_tags, {
    Name = local.target_group_name
  })
}

module "acm" {
  count = var.create_acm_certificate ? 1 : 0

  source = "../acm"

  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  validation_method         = var.acm_validation_method
  hosted_zone_id            = var.acm_hosted_zone_id
  create_route53_records    = var.acm_create_route53_records
  validation_record_ttl     = var.acm_validation_record_ttl
  wait_for_validation       = var.acm_wait_for_validation
  tags                      = var.tags
  certificate_tags          = var.acm_certificate_tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = upper(var.listener_protocol)
  certificate_arn   = upper(var.listener_protocol) == "HTTPS" ? local.resolved_listener_certificate_arn : null
  ssl_policy = upper(var.listener_protocol) == "HTTPS" ? coalesce(
    var.listener_ssl_policy,
    "ELBSecurityPolicy-TLS13-1-2-2021-06"
  ) : null

  dynamic "default_action" {
    for_each = var.listener_default_action_type == "forward" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = local.resolved_target_group_arn
    }
  }

  dynamic "default_action" {
    for_each = var.listener_default_action_type == "redirect" ? [1] : []
    content {
      type = "redirect"
      redirect {
        host        = var.redirect_host
        path        = var.redirect_path
        port        = var.redirect_port
        protocol    = var.redirect_protocol
        query       = var.redirect_query
        status_code = var.redirect_status_code
      }
    }
  }

  dynamic "default_action" {
    for_each = var.listener_default_action_type == "fixed-response" ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = var.fixed_response_content_type
        message_body = var.fixed_response_message_body
        status_code  = var.fixed_response_status_code
      }
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = local.resolved_target_group_arn == null ? {} : local.target_attachments

  target_group_arn  = local.resolved_target_group_arn
  target_id         = each.value.target_id
  availability_zone = try(each.value.availability_zone, null)
  port              = try(each.value.port, null)
}
