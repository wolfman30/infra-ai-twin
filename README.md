# infra-ai-twin

This repo will be built in small, verified steps. We’ll wire up:
- Bootstrap: Terraform state S3 bucket + DynamoDB lock (local backend for bootstrap itself)
- Deployer role: OIDC trust for GitHub Actions (sts:AssumeRoleWithWebIdentity + sts:TagSession)
- Environments (dev/staging/prod) using the state bucket

## Step 0 — Confirm AWS details (please answer)
- Account ID to use: 422017356225 (confirm)
- Primary region for resources (state + roles): us-east-2 (confirm)
- GitHub OIDC provider in IAM exists with URL `https://token.actions.githubusercontent.com` and client ID `sts.amazonaws.com`: confirm ARN
- Repos/branches to allow in the role trust `sub`:
  - repo: OWNER/REPO, branches: e.g., main, develop (list)
- Separate role per environment (dev/staging/prod) or a single role per account?
- Max session duration (e.g., 3600s)
- OK to allow session tagging (recommended): yes/no

## Step 1 — Bootstrap state (local backend)
Directory: `infra-ai-twin/bootstrap`
This creates the S3 state bucket and DynamoDB lock table.

Initialize and plan (requires AWS credentials configured locally):
- `cd infra-ai-twin/bootstrap`
- `terraform init`
- `terraform plan -var "region=<your-region>" -var "bucket_name=<globally-unique-bucket>" -var "lock_table_name=<table-name>"`
- Apply when ready: `terraform apply -auto-approve -var "region=<...>" -var "bucket_name=<...>" -var "lock_table_name=<...>"`

Outputs show the bucket and table ARNs for use in later steps.

## Step 2 — Deployer role (OIDC trust)
After Step 0 answers, we’ll add a small module to create the deployer role with:
- Principal: the GitHub OIDC provider ARN
- Actions: `sts:AssumeRoleWithWebIdentity`, `sts:TagSession`
- Conditions:
  - `iss = https://token.actions.githubusercontent.com`
  - `aud = sts.amazonaws.com`
  - `sub = repo:OWNER/REPO:*` (and branch-constrained if desired)

## Step 3 — Environments
Dev/staging/prod folders use the S3 backend + lock table, assume the deployer role, and add any service permissions needed (ECS/Lambda/etc.).

## Testing along the way
- Each step includes a small `plan`/`apply` target and a simple verification (e.g., `aws s3 ls s3://<bucket>`; `aws dynamodb describe-table ...`).
- For GitHub Actions, we’ll include a minimal job with `permissions: id-token: write` and a debug step to print token claims before assuming the role.

"# infra-ai-twin" 
