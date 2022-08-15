data "aws_iam_policy_document" "kms_key_default" {
  # checkov:skip=CKV_AWS_111: todo reduce perms on key
  # checkov:skip=CKV_AWS_109: ADD REASON
  statement {
    sid     = "KMS Key Default"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  # allow CloudWatch to use this key
  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
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

# Create EC2 Instance Role
resource "aws_iam_role" "ssm_role" {
  name_prefix = "ssm_role-"
  description = "Allows access to SSM resources"
  path        = "/"
  tags        = var.tags

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.ssm_s3_cwl_kms_access.arn,
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

data "aws_iam_policy_document" "ssm_s3_cwl_kms_access" {
  # checkov:skip=CKV_AWS_111: ADD REASON
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
      sid       = "S3EncryptionForSessionManager"
      actions   = ["s3:GetEncryptionConfiguration"]
      resources = [aws_s3_bucket.session_logs_bucket[0].arn]
    }
  }

  # CloudWatch Logs for Run Command
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-rc-setting-up-cwlogs.html
  dynamic "statement" {
    for_each = var.enable_log_to_cloudwatch ? [1] : []
    content {
      sid       = "CloudWatchLogsAccessForSessionManager"
      actions   = ["logs:DescribeLogGroups"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_log_to_cloudwatch ? [1] : []
    content {
      sid = "CloudWatchLogStreamsAccessForSessionManager"
      actions = [
        "logs:DescribeLogStreams",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = ["${aws_cloudwatch_log_group.session_manager_log_group[0].arn}:*"]
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
  name        = "ssm_s3_cwl_kms_access-${local.region}"
  description = "Allows access to SSM resources"
  path        = "/"
  policy      = data.aws_iam_policy_document.ssm_s3_cwl_kms_access.json
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name_prefix = "ssm_profile-"
  role        = aws_iam_role.ssm_role.name
}
