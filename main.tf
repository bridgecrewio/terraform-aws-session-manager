data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

<<<<<<< HEAD
data "aws_partition" "current" {}
=======
resource "aws_s3_bucket" "session_logs_bucket" {
  count         = var.enable_log_to_s3 ? 1 : 0
  bucket        = var.bucket_name == "" ? "ssm-session-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}" : var.bucket_name
  acl           = "private"
  force_destroy = true
  tags          = var.tags

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.ssmkey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "archive_after_X_days"
    enabled = true

    transition {
      days          = var.log_archive_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expire_days
    }
  }

  logging {
    target_bucket = aws_s3_bucket.access_log_bucket[0].id
    target_prefix = "log/"
  }

}

resource "aws_s3_bucket_public_access_block" "session_logs_bucket" {
  count                   = var.enable_log_to_s3 ? 1 : 0
  bucket                  = aws_s3_bucket.session_logs_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "access_log_bucket" {
  count         = var.enable_log_to_s3 ? 1 : 0
  bucket        = var.access_log_bucket_name == "" ? "ssm-session-access-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}" : var.access_log_bucket_name
  acl           = "log-delivery-write"
  force_destroy = true
  tags          = var.tags

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.ssmkey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "delete_after_X_days"
    enabled = true

    expiration {
      days = var.access_log_expire_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_log_bucket" {
  count                   = var.enable_log_to_s3 ? 1 : 0
  bucket                  = aws_s3_bucket.access_log_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "kms_key_default" {
  statement {
    sid = "KMS Key Default"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]

    resources = ["*"]

  }

  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]
  }

}

>>>>>>> 11ec0d3 (expanded module functionality)
resource "aws_kms_key" "ssmkey" {
  description             = "SSM key"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_default.json
  tags                    = var.tags
}

resource "aws_kms_alias" "ssmkey" {
  name_prefix   = "${var.kms_key_alias}-"
  target_key_id = aws_kms_key.ssmkey.key_id
}

resource "aws_cloudwatch_log_group" "session_manager_log_group" {
<<<<<<< HEAD
  name_prefix       = "${var.cloudwatch_log_group_name}-"
=======
  count             = var.enable_log_to_cloudwatch ? 1 : 0
  name              = var.cloudwatch_log_group_name
>>>>>>> 11ec0d3 (expanded module functionality)
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = aws_kms_key.ssmkey.arn
  tags              = var.tags
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"
  tags            = var.tags

  # https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-configure-preferences-cli.html
  content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "s3BucketName": "${var.enable_log_to_s3 ? aws_s3_bucket.session_logs_bucket[0].id : ""}",
        "s3KeyPrefix": "${var.enable_log_to_s3 ? var.bucket_key_prefix : ""}",
        "s3EncryptionEnabled": ${var.enable_log_to_s3 ? "true" : "false"},
        "cloudWatchLogGroupName": "${var.enable_log_to_cloudwatch ? aws_cloudwatch_log_group.session_manager_log_group.name : ""}",
        "cloudWatchEncryptionEnabled": ${var.enable_log_to_cloudwatch ? "true" : "false"},
        "idleSessionTimeout": "${var.idle_session_timeout}",
        "cloudWatchStreamingEnabled": true,
        "kmsKeyId": "${aws_kms_key.ssmkey.key_id}",
        "runAsEnabled": ${var.enable_run_as},
        "runAsDefaultUser": "${var.enable_run_as ? var.run_as_default_user : ""}",
        "shellProfile": {
          "windows": "${var.shell_profile_windows}",
          "linux": "${var.shell_profile_linux}"
        }
    }
}
DOC
}
<<<<<<< HEAD
=======

# Create EC2 Instance Role
resource "aws_iam_role" "ssm_role" {
  name        = "ssm_role"
  description = "Allows access to SSM resources"
  path        = "/"
  tags        = var.tags

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "ssm_s3_cwl_kms_access" {
  # A custom policy for S3 bucket access
  # https://docs.aws.amazon.com/en_us/systems-manager/latest/userguide/setup-instance-profile.html#instance-profile-custom-s3-policy
  dynamic "statement" {
    for_each = var.enable_log_to_s3 ? [1] : []
    content {
      sid = "S3BucketAccessForSessionManager"
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
      ]
      resources = [
        aws_s3_bucket.session_logs_bucket[0].arn,
        "${aws_s3_bucket.session_logs_bucket[0].arn}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.enable_log_to_s3 ? [1] : []
    content {
      sid = "S3EncryptionForSessionManager"
      actions = [
        "s3:GetEncryptionConfiguration",
      ]
      resources = [
        aws_s3_bucket.session_logs_bucket[0].arn
      ]
    }
  }

  # A custom policy for CloudWatch Logs access
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/permissions-reference-cwl.html
  dynamic "statement" {
    for_each = var.enable_log_to_cloudwatch ? [1] : []
    content {
      sid = "CloudWatchLogsAccessForSessionManager"
      actions = [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]
      resources = ["*"]
    }
  }

  statement {
    sid = "KMSEncryptionForSessionManager"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = [aws_kms_key.ssmkey.arn]
  }
}

resource "aws_iam_policy" "ssm_s3_cwl_kms_access" {
  name        = "ssm_s3_cwl_kms_access"
  description = "Allows access to SSM resources"
  path        = "/"
  policy      = data.aws_iam_policy_document.ssm_s3_cwl_kms_access.json
}

resource "aws_iam_role_policy_attachment" "SSM-role-policy-attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "SSM-s3-cwl-kms-policy-attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_s3_cwl_kms_access.arn
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ssm_role.name
}

>>>>>>> 11ec0d3 (expanded module functionality)
