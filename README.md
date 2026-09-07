# Receipt Tracker — Infrastructure

Terraform + Lambda source monorepo for the receipt tracker app on AWS (region: `eu-north-1`).

## Layout

```
bootstrap/     one-time setup: S3 state bucket (with native lockfile locking), GitHub Actions OIDC role
modules/       reusable Terraform modules (lambda, s3, api_gateway)
envs/          per-environment root configs (dev, prod)
functions/     Python Lambda source, one directory per function
scripts/       helper scripts (e.g. build_lambda.sh for functions with deps)
```

Authentication is **not yet implemented**. API Gateway routes are currently open; an auth
approach (Cognito or otherwise) will be layered in once decided.

## Prerequisites

- Terraform >= 1.10
- AWS CLI configured with credentials for the target account
- Python 3.13 (for local Lambda testing)

## One-time setup

1. **Create the remote state backend and GitHub Actions OIDC role:**
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```
   This creates the `receipt-tracker-tfstate` S3 bucket and an IAM role
   (`receipt-tracker-github-actions-deploy`) that
   `md-coops/receipt_scanner_infrastructure` can assume via GitHub's OIDC provider —
   no long-lived AWS keys stored in GitHub. Grab the role
   ARN afterward:
   ```bash
   terraform output -raw github_actions_role_arn
   ```

2. **Add the role ARN as a repo secret:** Settings → Secrets and variables → Actions →
   New repository secret, name `AWS_DEPLOY_ROLE_ARN`, value from the output above.

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
