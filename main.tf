data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}
resource "aws_kms_key" "ssmkey" {
  description             = "SSM Key"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_access.json
  tags                    = var.tags
}

resource "aws_kms_alias" "ssmkey" {
  name_prefix   = "${var.kms_key_alias}-"
  target_key_id = aws_kms_key.ssmkey.key_id
}

resource "aws_cloudwatch_log_group" "session_manager_log_group" {
  name_prefix       = "${var.cloudwatch_log_group_name}-"
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = aws_kms_key.ssmkey.arn

  tags = var.tags
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"
  tags            = var.tags

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = var.enable_log_to_s3 ? aws_s3_bucket.session_logs_bucket.id : ""
      s3EncryptionEnabled         = var.enable_log_to_s3 ? true : false
      cloudWatchLogGroupName      = var.enable_log_to_cloudwatch ? aws_cloudwatch_log_group.session_manager_log_group.name : ""
      cloudWatchEncryptionEnabled = var.enable_log_to_cloudwatch ? true : false
      kmsKeyId                    = aws_kms_key.ssmkey.key_id
      idleSessionTimeout          = "20"
      shellProfile = {
      #  linux   = var.linux_shell_profile == "" ? var.linux_shell_profile : ""
      #  windows = var.windows_shell_profile == "" ? var.windows_shell_profile : ""
        linux   = var.linux_shell_profile == "" ? "" : var.linux_shell_profile
        windows = var.windows_shell_profile == "" ? "" : var.windows_shell_profile
      }
    }
  })
}
