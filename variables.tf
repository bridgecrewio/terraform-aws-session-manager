variable "bucket_name" {
  description = "Name of S3 bucket to store session logs"
  type        = string
  default     = ""
}

variable "bucket_key_prefix" {
  description = "Name of S3 sub-folder (prefix)"
  type        = string
  default     = ""
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
  default     = ""
}

variable "access_log_expire_days" {
  description = "Number of days to wait before deleting access logs"
  type        = number
  default     = 30
}

variable "kms_key_deletion_window" {
  description = "Number of days to wait for scheduled KMS Key deletion [7-30]"
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

variable "idle_session_timeout" {
  description = "Number of minutes a user can be inactive before a session ends [1-60]"
  type        = number
  default     = 20
}

variable "run_as_default_user" {
  description = "OS default user name, if IAM user/role 'SSMSessionRunAs' tag is undefined"
  type        = string
  default     = "ssm-user"
}

variable "shell_profile_windows" {
  description = "Environment variables, shell preferences, or commands to run when session starts"
  type        = string
  default     = ""
}

variable "shell_profile_linux" {
  description = "Environment variables, shell preferences, or commands to run when session starts"
  type        = string
  default     = ""
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

variable "enable_run_as" {
  description = "Enable Run As support for Linux instances"
  type        = bool
  default     = false
}

variable "vpc_endpoints_enabled" {
  description = "Create VPC Endpoints"
  type        = bool
  default     = false
}

