resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket

  tags = {
    Environment = "${var.bucket_environment}"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}