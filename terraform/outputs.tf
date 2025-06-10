output "s3_bucket_name" {
  value       = aws_s3_bucket.main.id
  description = "The name of the S3 bucket"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "The ARN of the S3 bucket"
}
