# Receipt Tracker — Infrastructure

Terraform + Lambda source monorepo for the receipt tracker app on AWS (region: `eu-north-1`).

## Layout

```
bootstrap/     one-time setup: S3 state bucket + DynamoDB lock table
modules/       reusable Terraform modules (lambda, s3, api_gateway)
envs/          per-environment root configs (dev, prod)
functions/     Python Lambda source, one directory per function
scripts/       helper scripts (e.g. build_lambda.sh for functions with deps)
```

Authentication is **not yet implemented**. API Gateway routes are currently open; an auth
approach (Cognito or otherwise) will be layered in once decided.

## Prerequisites

- Terraform >= 1.9
- AWS CLI configured with credentials for the target account
- Python 3.13 (for local Lambda testing)

## One-time setup

1. **Create the remote state backend:**
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```
   This creates the `receipt-tracker-tfstate` S3 bucket and `receipt-tracker-tf-locks`
   DynamoDB table that every environment's backend points at.

2. **GitHub Actions AWS access:** the workflows assume an IAM role assumable via GitHub
   OIDC, referenced as the `AWS_DEPLOY_ROLE_ARN` repository secret. This role and its
   OIDC trust relationship must be created out-of-band (not managed by this repo).

3. **Prod approval gate:** create a `prod` GitHub Environment (Settings → Environments)
   with required reviewers, so `terraform-apply.yml` pauses for approval before applying
   `envs/prod`.

## Quickstart

```bash
make plan ENV=dev
make apply ENV=dev
```

## CI/CD

- `terraform-plan.yml` — runs `terraform plan` on pull requests and comments the result.
- `terraform-apply.yml` — on merge to `main`, applies `envs/dev` automatically, then
  `envs/prod` after manual approval via the `prod` GitHub Environment.

Both workflows require remote state (see one-time setup above) since GitHub-hosted
runners are ephemeral and cannot retain local state between runs.
