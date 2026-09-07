variable "api_name" {
  type = string
}

variable "routes" {
  description = "Routes to expose. No authorizer is attached yet — auth is deferred."
  type = list(object({
    route_key            = string
    lambda_invoke_arn    = string
    lambda_function_name = string
  }))
}

variable "cors_configuration" {
  type = object({
    allow_origins = list(string)
    allow_methods = list(string)
    allow_headers = list(string)
  })
  default = null
}

variable "stage_name" {
  type    = string
  default = "$default"
}

variable "tags" {
  type    = map(string)
  default = {}
}
