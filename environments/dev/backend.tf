terraform {
  backend "s3" {
    bucket         = "infra-ai-twin-tfstate-422017356225"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "infra-ai-twin-tf-locks"
    encrypt        = true
  }
}

