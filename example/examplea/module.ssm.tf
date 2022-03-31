module "ssm" {
  source                   = "../../"
  bucket_name              = "my-session-logs"
  access_log_bucket_name   = "my-session-access-logs"
  enable_log_to_s3         = true
  enable_log_to_cloudwatch = true
  linux_shell_profile      = "date"
}
