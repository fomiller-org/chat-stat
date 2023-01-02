locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment = local.environment_vars.locals.environment
  account_id  = local.account_vars.locals.account_id
}

terraform {
  source = "../../../modules/aws//elasticache"
}

dependencies {
    paths = ["../vpc"]
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {}

