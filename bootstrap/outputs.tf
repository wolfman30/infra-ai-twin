output "state_bucket_name" {
  value       = aws_s3_bucket.state.bucket
  description = "Terraform state bucket name"
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "Terraform state bucket ARN"
}

output "lock_table_name" {
  value       = aws_dynamodb_table.lock.name
  description = "Terraform state lock DynamoDB table name"
}

output "lock_table_arn" {
  value       = aws_dynamodb_table.lock.arn
  description = "Terraform state lock DynamoDB table ARN"
}

