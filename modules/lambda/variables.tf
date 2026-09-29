variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "source_dir" {
  type        = string
  description = "Path to the directory containing the Lambda source code"
}

variable "handler" {
  type        = string
  description = "Function entrypoint, e.g. handler.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.13"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "iam_policy_statements" {
  description = "Extra IAM statements granted to the function's execution role"
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "sns_topic_arns" {
  description = "SNS topics that invoke this function"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "tags" {
  type    = map(string)
  default = {}
}
