variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "state_bucket_name" {
  type    = string
  default = "receipt-tracker-tfstate"
}

variable "lock_table_name" {
  type    = string
  default = "receipt-tracker-tf-locks"
}
