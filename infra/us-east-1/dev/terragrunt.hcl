locals {
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
  environment = "dev"
}

generate provider {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~>4.0"
      }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "saml"
  default_tags {
      tags = {
          email = "forrestmillerj@gmail.com"
      }
  }
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
    app_prefix = "fomiller-chat-stat"
    extra_tags = {
    }
  }
)

