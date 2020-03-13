output "session_logs_bucket_name" {
  value = aws_s3_bucket.session_logs_bucket.id
}

output "access_log_bucket_name" {
  value = aws_s3_bucket.access_log_bucket.id
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.session_manager_log_group.arn
}

output "kms_key_arn" {
  value = aws_kms_key.ssmkey.arn
}

output "iam_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "iam_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}

output "ssm_security_group" {
  value = aws_security_group.ssm_sg.*.id
}

output "vpc_endpoint_ssm" {
  value = aws_vpc_endpoint.ssm.*.id
}

output "vpc_endpoint_ec2messages" {
  value = aws_vpc_endpoint.ec2messages.*.id
}

output "vpc_endpoint_ssmmessages" {
  value = aws_vpc_endpoint.ssmmessages.*.id
}

output "vpc_endpoint_s3" {
  value = aws_vpc_endpoint.s3.*.id
}

output "vpc_endpoint_logs" {
  value = aws_vpc_endpoint.logs.*.id
}

output "vpc_endpoint_kms" {
  value = aws_vpc_endpoint.kms.*.id
}
