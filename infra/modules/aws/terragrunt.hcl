locals {
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
  environment = "prod"
}

generate provider {
  path      = "provider.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  version = "~>5.0"
  region = "us-east-1"
  profile = "default"
  default_tags {
    tags = {
      email = "forrestmillerj@gmail.com"
      managedWith = "terraform"
    }
  }
}
EOF
}

generate variables {
  path      = "variable.gen.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "environment" {
    type = string
}
variable "app_prefix" {
    type = string
    default = "cs"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "fomiller-terraform-state-${local.environment}"
    key            = "chat-stat/${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "fomiller-terraform-state-lock"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.region_vars.locals,
  {
    app_prefix = "fomiller"
    extra_tags = {
    }
  }
)

terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else already has the lock
  extra_arguments "common" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "validate",
      "plan",
      "taint",
      "untaint",
      "destroy"
    ]
    env_vars = {
      TF_VAR_var_from_environment = "value"
    }
    required_var_files = [
      "${get_parent_terragrunt_dir()}/common.tfvars",
      "${get_terragrunt_dir()}/env-config/common.tfvars",
      "${get_terragrunt_dir()}/env-config/${get_env("TF_VAR_region", "us-east-1")}/${get_env("TF_VAR_env", "dev")}.tfvars",
    ]
  }
}
