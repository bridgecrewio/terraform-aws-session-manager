resource "aws_s3_bucket" "access_log_bucket" {
  # checkov:skip=CKV_AWS_144: Cross region replication is overkill
  # checkov:skip=CKV_AWS_18:
  # checkov:skip=CKV_AWS_52:
  # checkov:skip=CKV_AWS_145:v4 provider legacy
  bucket_prefix = "${var.access_log_bucket_name}-"
  force_destroy = true

  tags = var.tags


}

resource "aws_s3_bucket_ownership_controls" "access_log_bucket" {
  bucket   = aws_s3_bucket.access_log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  acl = "log-delivery-write"
  depends_on = [
	  aws_s3_bucket_ownership_controls.access_log_bucket,
  ]
}


resource "aws_s3_bucket_versioning" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ssmkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  rule {
    id     = "delete_after_X_days"
    status = "Enabled"

    expiration {
      days = var.access_log_expire_days
    }
  }
}


resource "aws_s3_bucket_public_access_block" "access_log_bucket" {
  bucket                  = aws_s3_bucket.access_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
