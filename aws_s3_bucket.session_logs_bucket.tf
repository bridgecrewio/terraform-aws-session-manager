resource "aws_s3_bucket" "session_logs_bucket" {
  # checkov:skip=CKV_AWS_144: Cross region replication overkill
  # checkov:skip=CKV_AWS_52:
  # checkov:skip=CKV_AWS_145:v4 provider legacy
  count         = var.enable_log_to_s3 ? 1 : 0
  bucket_prefix = "${var.bucket_name}-"
  force_destroy = true
  tags          = var.tags
}


resource "aws_s3_bucket_acl" "session_logs_bucket" {
  count  = var.enable_log_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.session_logs_bucket[0].id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "session_logs_bucket" {
  count  = var.enable_log_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.session_logs_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "session_logs_bucket" {
  count  = var.enable_log_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.session_logs_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ssmkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "session_logs_bucket" {
  count  = var.enable_log_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.session_logs_bucket[0].id

  rule {
    id     = "archive_after_X_days"
    status = "Enabled"

    transition {
      days          = var.log_archive_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expire_days
    }
  }
}

resource "aws_s3_bucket_logging" "session_logs_bucket" {
  count  = var.enable_log_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.session_logs_bucket[0].id

  target_bucket = aws_s3_bucket.access_logs_bucket[0].id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "session_logs_bucket" {
  count                   = var.enable_log_to_s3 ? 1 : 0
  bucket                  = aws_s3_bucket.session_logs_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
