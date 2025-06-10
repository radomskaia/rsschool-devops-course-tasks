variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "bucket-radomskaia-1"
}
