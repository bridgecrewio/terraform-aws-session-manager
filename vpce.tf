data "aws_vpc" "selected" {
  count = var.vpc_endpoints_enabled ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnet_ids" "selected" {
  count  = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id = var.vpc_id
}

locals {
  subnet_ids_string = join(",", data.aws_subnet_ids.selected[0].ids)
  subnet_ids_list   = split(",", local.subnet_ids_string)
}

data "aws_route_table" "selected" {
  count     = var.vpc_endpoints_enabled ? length(data.aws_subnet_ids.selected[0].ids) : 0
  subnet_id = sort(data.aws_subnet_ids.selected[0].ids)[count.index]
}

# Create VPC Endpoints For Session Manager 
resource "aws_security_group" "ssm_sg" {
  count       = var.vpc_endpoints_enabled ? 1 : 0
  name        = "ssm-sg"
  description = "Allow TLS inbound To AWS Systems Manager Session Manager"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    description = "Allow All Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

# SSM, EC2Messages, and SSMMessages endpoints are required for Session Manager
resource "aws_vpc_endpoint" "ssm" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = data.aws_subnet_ids.selected[0].ids
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = data.aws_subnet_ids.selected[0].ids
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = true
  tags                = var.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = data.aws_subnet_ids.selected[0].ids
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id,
  ]

  private_dns_enabled = true
  tags                = var.tags
}

# To write session logs to S3, an S3 endpoint is needed:
resource "aws_vpc_endpoint" "s3" {
  count        = var.vpc_endpoints_enabled && var.enable_log_to_s3 ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
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
  subnet_ids        = data.aws_subnet_ids.selected[0].ids
  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

# To Encrypt/Decrypt, a KMS endpoint is needed
resource "aws_vpc_endpoint" "kms" {
  count             = var.vpc_endpoints_enabled ? 1 : 0
  vpc_id            = var.vpc_id
  subnet_ids        = data.aws_subnet_ids.selected[0].ids
  service_name      = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_sg[0].id
  ]

  private_dns_enabled = true
  tags                = var.tags
}

