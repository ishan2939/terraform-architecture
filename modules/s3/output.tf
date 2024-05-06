output "s3_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "s3_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "s3_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}