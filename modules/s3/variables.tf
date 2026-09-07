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

variable "tags" {
  type    = map(string)
  default = {}
}
