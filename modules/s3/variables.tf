variable "bucket_name" {
  type = string
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "enable_cors" {
  type    = bool
  default = false
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = ["*"]
}

variable "lifecycle_days" {
  type        = number
  default     = 0
  description = "Days after which objects expire. 0 disables the lifecycle rule."
}

variable "log_retention_days" {
  type        = number
  default     = 14
  description = "Retention for the SNS delivery-status log groups."
}

variable "sns_success_sample_rate" {
  type        = number
  default     = 100
  description = "Percentage (0-100) of successful SNS deliveries to log."

  validation {
    condition     = var.sns_success_sample_rate >= 0 && var.sns_success_sample_rate <= 100
    error_message = "sns_success_sample_rate must be between 0 and 100."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
