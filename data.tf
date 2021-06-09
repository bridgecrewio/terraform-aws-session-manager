data "aws_vpc" "selected" {
  count = var.vpc_endpoints_enabled ? 1 : 0
  id    = var.vpc_id
}
