resource "aws_s3_bucket" "logs_bucket" {
  count = var.enable_access_logs == true ? 1 : 0

  bucket = "${var.module_prefix}-logs-bucket"
}

resource "aws_s3_bucket_ownership_controls" "logs_bucket_ownership" {
  count = var.enable_access_logs == true ? 1 : 0

  bucket = aws_s3_bucket.logs_bucket[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_bucket_ownership[0]]

  bucket = aws_s3_bucket.logs_bucket[0].id
  acl    = "private"
}
