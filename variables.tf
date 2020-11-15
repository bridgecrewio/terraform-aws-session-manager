variable "bucket_name" {
  description = "Name of S3 bucket to store session logs"
  type        = string
}

variable "log_archive_days" {
  description = "Number of days to wait before archiving to Glacier"
  type        = number
  default     = 30
}

variable "log_expire_days" {
  description = "Number of days to wait before deleting"
  type        = number
  default     = 365
}

variable "access_log_bucket_name" {
  description = "Name of S3 bucket to store access logs from session logs bucket"
  type        = string
}

variable "access_log_expire_days" {
  description = "Number of days to wait before deleting access logs"
  type        = number
  default     = 30
}

variable "kms_key_deletion_window" {
  description = "Waiting period for scheduled KMS Key deletion.  Can be 7-30 days." 
  type        = number
  default     = 7
}

variable "kms_key_alias" {
  description = "Alias of the KMS key.  Must start with alias/ followed by a name"
  type        = string
  default     = "alias/ssm-key"
}

variable "cloudwatch_logs_retention" {
  description = "Number of days to retain Session Logs in CloudWatch"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for storing SSM Session Logs"
  type        = string
  default     = "/ssm/session-logs"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID to deploy endpoints into"
  type        = string
  default     = null
}

variable "enable_log_to_s3" {
  description = "Enable Session Manager to Log to S3"
  type        = bool 
  default     = true
}

variable "enable_log_to_cloudwatch" {
  description = "Enable Session Manager to Log to CloudWatch Logs"
  type        = bool 
  default     = true
}

variable "vpc_endpoints_enabled" {
  description = "Create VPC Endpoints"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "Name for IAM role"
  type = string
  default = "ssm_iam_role"
}