terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  account_id               = "422017356225"
  state_bucket_name        = "infra-ai-twin-tfstate-422017356225"
  state_bucket_arn         = "arn:aws:s3:::infra-ai-twin-tfstate-422017356225"
  state_lock_table_arn     = "arn:aws:dynamodb:us-east-2:${local.account_id}:table/infra-ai-twin-tf-locks"
  github_oidc_provider_arn = "arn:aws:iam::422017356225:oidc-provider/token.actions.githubusercontent.com"
}

module "deployer_role" {
  source                   = "../../modules/deployer-role"
  role_name                = "ai-twin-devops-dev"
  github_oidc_provider_arn = local.github_oidc_provider_arn
  allowed_subs             = [
    "repo:wolfman30/infra-ai-twin:ref:refs/heads/main"
  ]
  state_bucket_arn        = local.state_bucket_arn
  state_bucket_prefixes   = ["dev/"]
  state_lock_table_arns   = [local.state_lock_table_arn]
  max_session_duration    = 3600
  tags = {
    ManagedBy = "Terraform"
    Service   = "ai-twin"
    Env       = "dev"
  }
}

output "deployer_role_arn" {
  value       = module.deployer_role.role_arn
  description = "Deployer role ARN for dev"
}

