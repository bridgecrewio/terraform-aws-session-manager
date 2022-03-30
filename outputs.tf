output "session_logs_bucket_name" {
  description = "S3 bucket for session logs"
  value       = concat(aws_s3_bucket.session_logs_bucket.*.id, [""])[0]
}

output "access_log_bucket_name" {
  description = "S3 bucket for S3 access logs"
  value       = concat(aws_s3_bucket.access_log_bucket.*.id, [""])[0]
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch Log group for session logs"
  value       = concat(aws_cloudwatch_log_group.session_manager_log_group.*.arn, [""])[0]
}

output "kms_key_arn" {
  description = "KMS Key Arn for Encrypting logs and session"
  value       = aws_kms_key.ssmkey.arn
}

output "iam_policy_arn" {
  description = "IAM Policy for EC2 instances"
  value       = aws_iam_policy.ssm_s3_cwl_kms_access.arn
}

output "iam_role_arn" {
  description = "EC2 instance profile for SSM"
  value       = aws_iam_role.ssm_role.arn
}

output "iam_profile_name" {
  description = "EC2 instance profile for SSM"
  value       = aws_iam_instance_profile.ssm_profile.name
}

output "document_name" {
  description = "Name of the created document"
  value       = aws_ssm_document.session_manager_prefs.name
}

output "document_arn" {
  description = "ARN of the created document. This can be used to create IAM policies that prevent changes to session manager preferences"
  value       = aws_ssm_document.session_manager_prefs.arn
}

output "ssm_security_group" {
  description = "Security Group used to access VPC Endpoints"
  value       = aws_security_group.ssm_sg.*.id
}

output "vpc_endpoint_ssm" {
  description = "VPC Endpoint for SSM"
  value       = aws_vpc_endpoint.ssm.*.id
}

output "vpc_endpoint_ec2messages" {
  description = "VPC Endpoint for EC2 Messages"
  value       = aws_vpc_endpoint.ec2messages.*.id
}

output "vpc_endpoint_ssmmessages" {
  description = "VPC Endpoint for SSM Messages"
  value       = aws_vpc_endpoint.ssmmessages.*.id
}

output "vpc_endpoint_s3" {
  description = "VPC Endpoint for S3"
  value       = aws_vpc_endpoint.s3.*.id
}

output "vpc_endpoint_logs" {
  description = "VPC Endpoint for CloudWatch Logs"
  value       = aws_vpc_endpoint.logs.*.id
}

output "vpc_endpoint_kms" {
  description = "VPC Endpoint for KMS"
  value       = aws_vpc_endpoint.kms.*.id
}
