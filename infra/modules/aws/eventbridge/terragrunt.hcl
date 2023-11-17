locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment = local.environment_vars.locals.environment
  account_id  = local.account_vars.locals.account_id
}

terraform {
  source = "../../../modules/aws//eventbridge"
}

dependency "ecs" {
    config_path = "../ecs/"
    mock_outputs = {
        cs_ecs_cluster_arn = "arn:aws:ecs:us-east-1:${local.account_id}:cluster/MOCK-cluster-arn"
        cs_api_task_def_arn = "arn:aws:ecs:us-east-1:${local.account_id}:task-definition/MOCK-task-def-arn"
    }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
   cs_ecs_cluster_arn = dependency.ecs.outputs.cs_ecs_cluster_arn
   cs_api_task_def_arn = dependency.ecs.outputs.cs_api_task_def_arn
}
