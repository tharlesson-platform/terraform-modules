data "aws_region" "current" {}

locals {
  public_subnets = {
    for index, cidr in var.public_subnet_cidrs : format("%02d", index) => {
      cidr = cidr
      az   = var.azs[index]
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs : format("%02d", index) => {
      cidr = cidr
      az   = var.azs[index]
    }
  }

  database_subnets = {
    for index, cidr in var.database_subnet_cidrs : format("%02d", index) => {
      cidr = cidr
      az   = var.azs[index]
    }
  }

  nat_gateway_count = (
    var.enable_nat_gateway && length(var.private_subnet_cidrs) > 0 && length(var.public_subnet_cidrs) > 0 ? (
      var.single_nat_gateway ? 1 : (
        var.one_nat_gateway_per_az ? length(var.public_subnet_cidrs) :
        min(length(var.private_subnet_cidrs), length(var.public_subnet_cidrs))
      )
    ) : 0
  )

  public_subnet_keys   = sort(keys(local.public_subnets))
  private_subnet_keys  = sort(keys(local.private_subnets))
  database_subnet_keys = sort(keys(local.database_subnets))

  private_nat_gateway_index = local.nat_gateway_count > 0 ? {
    for idx, key in local.private_subnet_keys :
    key => (
      var.single_nat_gateway ? 0 : (
        var.one_nat_gateway_per_az ? idx % length(local.public_subnet_keys) :
        idx % local.nat_gateway_count
      )
    )
  } : {}

  database_nat_gateway_index = local.nat_gateway_count > 0 ? {
    for idx, key in local.database_subnet_keys :
    key => (
      var.single_nat_gateway ? 0 : (
        var.one_nat_gateway_per_az ? idx % length(local.public_subnet_keys) :
        idx % local.nat_gateway_count
      )
    )
  } : {}

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "vpc"
    VpcName   = var.name
  })

  flow_logs_log_group_name = coalesce(var.flow_logs_log_group_name, "/aws/vpc-flow-logs/${var.name}")
  flow_logs_iam_role_name  = coalesce(var.flow_logs_iam_role_name, "${var.name}-vpc-flow-logs-role")
}

check "nat_mode_is_exclusive" {
  assert {
    condition     = !(var.single_nat_gateway && var.one_nat_gateway_per_az)
    error_message = "single_nat_gateway and one_nat_gateway_per_az cannot both be true."
  }
}

check "nat_requires_igw" {
  assert {
    condition     = !var.enable_nat_gateway || var.enable_internet_gateway
    error_message = "NAT Gateway requires enable_internet_gateway = true."
  }
}

check "nat_requires_public_and_private_subnets" {
  assert {
    condition     = !var.enable_nat_gateway || (length(var.public_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) > 0)
    error_message = "enable_nat_gateway = true requires at least one public subnet and one private subnet."
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  tags = merge(local.common_tags, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "this" {
  count = var.enable_internet_gateway && length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.common_tags, var.public_subnet_tags, {
    Name = "${var.name}-public-${each.value.az}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, var.private_subnet_tags, {
    Name = "${var.name}-private-${each.value.az}"
    Tier = "private"
  })
}

resource "aws_subnet" "database" {
  for_each = local.database_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, var.database_subnet_tags, {
    Name = "${var.name}-database-${each.value.az}"
    Tier = "database"
  })
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(local.common_tags, var.nat_gateway_tags, {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[
    local.public_subnet_keys[var.single_nat_gateway ? 0 : count.index % length(local.public_subnet_keys)]
  ].id

  tags = merge(local.common_tags, var.nat_gateway_tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count = length(local.public_subnets) > 0 && var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
    Tier = "public"
  })
}

resource "aws_route" "public_internet" {
  count = length(aws_route_table.public) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = length(aws_route_table.public) > 0 ? local.public_subnets : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-rt-${each.value.az}"
    Tier = "private"
  })
}

resource "aws_route" "private_default" {
  for_each = local.nat_gateway_count > 0 ? local.private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[local.private_nat_gateway_index[each.key]].id
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "database" {
  for_each = local.database_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-database-rt-${each.value.az}"
    Tier = "database"
  })
}

resource "aws_route" "database_default" {
  for_each = local.nat_gateway_count > 0 && var.database_subnet_route_to_nat_gateway ? local.database_subnets : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[local.database_nat_gateway_index[each.key]].id
}

resource "aws_route_table_association" "database" {
  for_each = local.database_subnets

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.key].id
}

resource "aws_db_subnet_group" "this" {
  count = var.create_database_subnet_group && length(local.database_subnets) > 0 ? 1 : 0

  name = coalesce(var.database_subnet_group_name, "${var.name}-db-subnet-group")
  subnet_ids = [
    for key in local.database_subnet_keys : aws_subnet.database[key].id
  ]

  tags = merge(local.common_tags, var.database_subnet_tags, {
    Name = coalesce(var.database_subnet_group_name, "${var.name}-db-subnet-group")
  })
}

locals {
  gateway_endpoint_route_table_ids = distinct(compact(concat(
    var.attach_gateway_endpoints_to_public ? [try(aws_route_table.public[0].id, null)] : [],
    var.attach_gateway_endpoints_to_private ? [for key in sort(keys(aws_route_table.private)) : aws_route_table.private[key].id] : [],
    var.attach_gateway_endpoints_to_database ? [for key in sort(keys(aws_route_table.database)) : aws_route_table.database[key].id] : []
  )))
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint && length(local.gateway_endpoint_route_table_ids) > 0 ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.gateway_endpoint_route_table_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-s3-gateway-endpoint"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_gateway_endpoint && length(local.gateway_endpoint_route_table_ids) > 0 ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.gateway_endpoint_route_table_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-dynamodb-gateway-endpoint"
  })
}

resource "aws_default_security_group" "this" {
  count = var.manage_default_security_group ? 1 : 0

  vpc_id                 = aws_vpc.this.id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-default-sg"
  })
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = local.flow_logs_log_group_name
  retention_in_days = var.flow_logs_retention_in_days
  kms_key_id        = var.flow_logs_kms_key_id

  tags = merge(local.common_tags, var.flow_logs_tags, {
    Name = "${var.name}-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name               = local.flow_logs_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json

  tags = merge(local.common_tags, var.flow_logs_tags, {
    Name = local.flow_logs_iam_role_name
  })
}

data "aws_iam_policy_document" "flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.flow_logs[0].arn}:*"]
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name   = "${local.flow_logs_iam_role_name}-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_policy[0].json
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  traffic_type             = upper(var.flow_logs_traffic_type)
  max_aggregation_interval = var.flow_logs_max_aggregation_interval
  vpc_id                   = aws_vpc.this.id

  tags = merge(local.common_tags, var.flow_logs_tags, {
    Name = "${var.name}-flow-log"
  })
}
