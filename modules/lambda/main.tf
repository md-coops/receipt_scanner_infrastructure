data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/../../build/${var.function_name}.zip"
  excludes    = ["tests", "requirements.txt", "__pycache__"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "extra" {
  count = length(var.iam_policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_policy_statements
    content {
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role_policy" "extra" {
  count  = length(var.iam_policy_statements) > 0 ? 1 : 0
  name   = "${var.function_name}-extra"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.extra[0].json
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  depends_on = [aws_cloudwatch_log_group.this]

  tags = var.tags
}

# count rather than for_each: topic ARNs are often unknown until apply.
resource "aws_lambda_permission" "sns" {
  count = length(var.sns_topic_arns)

  statement_id  = "AllowSNSInvoke-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arns[count.index]
}

resource "aws_sns_topic_subscription" "this" {
  count = length(var.sns_topic_arns)

  topic_arn = var.sns_topic_arns[count.index]
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn

  depends_on = [aws_lambda_permission.sns]
}
