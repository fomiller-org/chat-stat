variable "lambda_role" {
  description = "lambda role arn"
  type        = string
  default = "LambdaHelloWorld"    
}

variable "lambda_name" {
  description = "name of lambda function"
  type        = string
  default = "hello-world"
}

variable "handler" {
  description = "handler for lambda"
  type        = string
  default = "lambda-go"
}

variable "filename" {
  description = "filename of lambda function"
  type        = string
  default = "./lambda_function.zip" 
}

variable "timeout" {
  description = "lambda timeout default (10)"
  type        = number
  default     = 10
}


variable "memory_size" {
  description = "ram allocation"
  type        = string
  default     = 128
}
