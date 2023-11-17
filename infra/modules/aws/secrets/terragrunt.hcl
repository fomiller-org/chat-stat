dependency "kms" {
    config_path = "../kms/"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs = {
        chat_stat_master_kms_key_arn = "arn:kms:us-east-1:${get_env("TF_VAR_account_id")}:MOCK-kms-arn"
    }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
   chat_stat_master_kms_key_arn = dependency.kms.outputs.chat_stat_master_kms_key_arn  
}
