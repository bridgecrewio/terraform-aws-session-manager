output "session_logs_bucket_name" {
  value = module.ssm.session_logs_bucket_name
}

output "access_log_bucket_name" {
  value = module.ssm.access_log_bucket_name
}

output "cloudwatch_log_group_arn" {
  value = module.ssm.cloudwatch_log_group_arn
}

output "kms_key_arn" {
  value = module.ssm.kms_key_arn
}

output "iam_role_arn" {
  value = module.ssm.iam_role_arn
}

output "iam_profile_name" {
  value = module.ssm.iam_profile_name
}

output "ssm_security_group" {
  value = module.ssm.ssm_security_group
}

output "vpc_endpoint_ssm" {
  value = module.ssm.vpc_endpoint_ssm
}

output "vpc_endpoint_ec2messages" {
  value = module.ssm.vpc_endpoint_ec2messages
}

output "vpc_endpoint_ssmmessages" {
  value = module.ssm.vpc_endpoint_ssmmessages
}

output "vpc_endpoint_s3" {
  value = module.ssm.vpc_endpoint_s3
}

output "vpc_endpoint_logs" {
  value = module.ssm.vpc_endpoint_logs
}

output "vpc_endpoint_kms" {
  value = module.ssm.vpc_endpoint_kms
}
