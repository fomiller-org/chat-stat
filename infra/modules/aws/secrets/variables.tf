variable "terraform_pass" {
  type    = string
  default = "user1234"
}

variable "terraform_user" {
  type    = string
  default = "pass1234"
}

variable "chat_stat_master_kms_key_arn" {
  description = "arn of the chat stat master kms key"
  type        = string
}
