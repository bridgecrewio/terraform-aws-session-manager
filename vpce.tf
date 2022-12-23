locals {
  region  = var.vpc_endpoints_enabled && var.vpc_id != null ? split(":", data.aws_vpc.selected[0].arn)[3] : data.aws_region.current.name
  subnets = var.vpc_endpoints_enabled ? var.subnet_ids != [] ? var.subnet_ids : data.aws_subnets.selected[0].ids : []
}

data "aws_subnets" "selected" {
  count = var.vpc_endpoints_enabled ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_route_table" "selected" {
  count     = var.vpc_endpoints_enabled ? length(local.subnets) : 0
  subnet_id = sort(local.subnets)[count.index]
}

# SSM, EC2Messages, and SSMMessages endpoints are required for Session Manager
resource "aws_vpc_endpoint" "ssm" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = local.subnets
  service_name      = "com.amazonaws.${local.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = local.subnets
  service_name      = "com.amazonaws.${local.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = local.subnets
  service_name      = "com.amazonaws.${local.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = var.tags
}

# To write session logs to S3, an S3 endpoint is needed:
resource "aws_vpc_endpoint" "s3" {
  count        = var.vpc_endpoints_enabled && var.enable_log_to_s3 ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
  tags         = var.tags
}

# Associate S3 Gateway Endpoint to VPC and Subnets
resource "aws_vpc_endpoint_route_table_association" "private_s3_route" {
  count           = var.vpc_endpoints_enabled && var.enable_log_to_s3 ? 1 : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = data.aws_vpc.selected[0].main_route_table_id
}

resource "aws_vpc_endpoint_route_table_association" "private_s3_subnet_route" {
  count           = var.vpc_endpoints_enabled && var.enable_log_to_s3 ? length(data.aws_route_table.selected) : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = data.aws_route_table.selected[count.index].id
}

# To write session logs to CloudWatch, a CloudWatch endpoint is needed
resource "aws_vpc_endpoint" "logs" {
  count             = var.vpc_endpoints_enabled && var.enable_log_to_cloudwatch ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = local.subnets
  service_name      = "com.amazonaws.${local.region}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = var.tags
}

# To Encrypt/Decrypt, a KMS endpoint is needed
resource "aws_vpc_endpoint" "kms" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = local.subnets
  service_name      = "com.amazonaws.${local.region}.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  tags                = var.tags
}
