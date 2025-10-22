variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  type        = string
}

variable "allowed_subs" {
  description = "List of allowed token sub values (e.g., repo:OWNER/REPO:ref:refs/heads/main)"
  type        = list(string)
}

variable "audience" {
  description = "OIDC audience to allow"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "issuer" {
  description = "OIDC token issuer URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "state_bucket_arn" {
  description = "Terraform state bucket ARN"
  type        = string
}

variable "state_bucket_prefixes" {
  description = "Prefixes within the state bucket this role may access"
  type        = list(string)
  default     = []
}

variable "state_lock_table_arns" {
  description = "DynamoDB table ARNs used for Terraform state locking"
  type        = list(string)
}

variable "max_session_duration" {
  description = "Max session duration in seconds"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}

