terraform {
  backend "s3" {
    bucket         = "terraform-state-radomskaia"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-1" # Сингапур
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

