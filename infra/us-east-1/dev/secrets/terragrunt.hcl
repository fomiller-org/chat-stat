locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment = local.environment_vars.locals.environment
  account_id  = local.account_vars.locals.account_id
}

terraform {
  source = "../../../modules/aws//secrets"
}

dependency "kms" {
    config_path = "../kms/"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs = {
        chat_stat_master_kms_key_arn = "arn:kms:us-east-1:0123456789012:MOCK-kms-arn"
    }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
   chat_stat_master_kms_key_arn = dependency.kms.outputs.chat_stat_master_kms_key_arn  
}


