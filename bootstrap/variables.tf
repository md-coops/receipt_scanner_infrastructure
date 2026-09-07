variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "state_bucket_name" {
  type    = string
  default = "receipt-tracker-tfstate"
}

variable "project_name" {
  type    = string
  default = "receipt-tracker"
}

variable "github_org" {
  type    = string
  default = "md-coops"
}

variable "github_org_id" {
  type        = string
  description = "Numeric GitHub org ID"
  default     = "67900948"
}

variable "github_repo_name" {
  type    = string
  default = "receipt_scanner_infrastructure"
}

variable "github_repo_id" {
  type        = string
  description = "Numeric GitHub repository ID"
  default     = "1360164834"
}
