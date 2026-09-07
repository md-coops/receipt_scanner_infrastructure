locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "receipts_bucket" {
  source      = "../../modules/s3"
  bucket_name = "${var.project_name}-${var.environment}-receipts"
  enable_cors = true
  tags        = local.common_tags
}

module "receipt_upload_lambda" {
  source        = "../../modules/lambda"
  function_name = "${var.project_name}-${var.environment}-receipt-upload"
  source_dir    = "${path.module}/../../functions/receipt_upload"
  handler       = "handler.lambda_handler"

  environment_variables = {
    RECEIPTS_BUCKET = module.receipts_bucket.bucket_name
  }

  iam_policy_statements = [{
    actions   = ["s3:PutObject"]
    resources = ["${module.receipts_bucket.bucket_arn}/*"]
  }]

  tags = local.common_tags
}

module "receipt_process_lambda" {
  source        = "../../modules/lambda"
  function_name = "${var.project_name}-${var.environment}-receipt-process"
  source_dir    = "${path.module}/../../functions/receipt_process"
  handler       = "handler.lambda_handler"

  environment_variables = {
    RECEIPTS_BUCKET = module.receipts_bucket.bucket_name
  }

  iam_policy_statements = [{
    actions   = ["s3:GetObject"]
    resources = ["${module.receipts_bucket.bucket_arn}/*"]
  }]

  tags = local.common_tags
}

module "api" {
  source   = "../../modules/api_gateway"
  api_name = "${var.project_name}-${var.environment}"

  routes = [
    {
      route_key            = "POST /receipts"
      lambda_invoke_arn    = module.receipt_upload_lambda.invoke_arn
      lambda_function_name = module.receipt_upload_lambda.function_name
    },
    {
      route_key            = "GET /receipts/{id}"
      lambda_invoke_arn    = module.receipt_process_lambda.invoke_arn
      lambda_function_name = module.receipt_process_lambda.function_name
    },
  ]

  tags = local.common_tags
}
