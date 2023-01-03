## default
variable "app_prefix" {
  description = "naming prefix for aws resources"
  type        = string
}

## lambda
variable "lambda_role" {
  description = "lambda role arn"
  type        = string
}

variable "lambda_name" {
  description = "name of lambda function"
  type        = string
}

variable "handler" {
  description = "handler for lambda"
  type        = string
}

variable "timeout" {
  description = "lambda timeout default (10)"
  type        = number
  default     = 10
}

# variable "runtime" {
#     description = "lambda runtime"
#     type = string
# }

variable "memory_size" {
  description = "ram allocation"
  type        = string
  default     = 128
}

# variable "source_code_hash" {
#     description = "source code hash"
#     type = string
# }

variable "filename" {
  description = "filename of lambda function"
  type        = string
}

