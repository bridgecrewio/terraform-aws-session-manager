locals {
  region  = var.vpc_endpoints_enabled && var.vpc_id != null ? split(":", data.aws_vpc.selected[0].arn)[3] : data.aws_region.current.name
  subnets = var.vpc_endpoints_enabled ? var.subnet_ids != [] ? var.subnet_ids : data.aws_subnets.selected[0].ids : []
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_vpc" "selected" {
  count = var.vpc_endpoints_enabled ? 1 : 0
  id    = var.vpc_id
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

