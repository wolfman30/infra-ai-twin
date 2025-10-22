terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession"
    ]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values   = [var.issuer]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [var.audience]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subs
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = "GitHub Actions deployer role (Terraform state + locks)"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = var.max_session_duration
  tags                 = var.tags

  lifecycle {
    ignore_changes = [
      description
    ]
  }
}

data "aws_iam_policy_document" "inline" {
  statement {
    sid    = "TerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = concat(
      [var.state_bucket_arn],
      [for prefix in var.state_bucket_prefixes : "${var.state_bucket_arn}/${prefix}*"]
    )
  }

  statement {
    sid    = "TerraformLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = var.state_lock_table_arns
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.role_name}-base"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline.json
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "The ARN of the created deployer role"
}
