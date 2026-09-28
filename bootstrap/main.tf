terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# --- GitHub Actions OIDC federation -----------------------------------------
# Lets GitHub Actions assume an AWS role using short-lived tokens instead of
# long-lived access keys stored as repo secrets.

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Trusts pushes to main (apply workflow), the prod environment job (whose
    # sub is environment-scoped rather than ref-scoped) and any PR from this
    # repo (plan workflow). Permissions, not this trust scope, are the real
    # boundary.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}@${var.github_org_id}/${var.github_repo_name}@${var.github_repo_id}:ref:refs/heads/main",
        "repo:${var.github_org}@${var.github_org_id}/${var.github_repo_name}@${var.github_repo_id}:environment:prod",
        "repo:${var.github_org}@${var.github_org_id}/${var.github_repo_name}@${var.github_repo_id}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = "${var.project_name}-github-actions-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_deploy_permissions" {
  statement {
    sid = "TerraformStateBucket"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*",
    ]
  }

  statement {
    sid = "ManageAppBuckets"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketVersioning",
      "s3:GetBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketCORS",
      "s3:GetBucketCORS",
      "s3:PutLifecycleConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:GetBucketPolicy",
      "s3:GetBucketAcl",
      "s3:GetBucketWebsite",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketLogging",
      "s3:GetReplicationConfiguration",
      "s3:GetBucketObjectLockConfiguration",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
      "arn:aws:s3:::${var.project_name}-*/*",
    ]
  }

  statement {
    sid = "ManageLambdaFunctions"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunctionConfiguration",
      "lambda:ListVersionsByFunction",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:ListTags",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:GetPolicy",
      "lambda:GetFunctionCodeSigningConfig",
    ]
    resources = ["arn:aws:lambda:*:*:function:${var.project_name}-*"]
  }

  statement {
    sid     = "ManageApiGateway"
    actions = ["apigateway:*"]
    resources = [
      "arn:aws:apigateway:*::/apis",
      "arn:aws:apigateway:*::/apis/*",
      "arn:aws:apigateway:*::/tags/*",
    ]
  }

  statement {
    sid = "ManageLambdaExecutionRoles"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
    ]
    resources = ["arn:aws:iam::*:role/${var.project_name}-*"]
  }

  statement {
    sid = "ManageLambdaLogGroups"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:ListTagsForResource",
      "logs:TagResource",
      "logs:UntagResource",
      "logs:TagLogGroup",
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-*"]
  }

  statement {
    sid = "ListLambdaLogGroups"
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = ["arn:aws:logs:*:*:log-group::log-stream:*"]
  }
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name   = "${var.project_name}-deploy-permissions"
  role   = aws_iam_role.github_actions_deploy.id
  policy = data.aws_iam_policy_document.github_actions_deploy_permissions.json
}
