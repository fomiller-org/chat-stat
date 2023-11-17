include "root" {
  path = find_in_parent_folders()
}

dependency "ecs" {
    config_path = "../ecs"
    mock_outputs = {
        cs_ecs_cluster_arn = "arn:aws:ecs:us-east-1:${get_env("TF_VAR_account_id")}:cluster/MOCK-cluster-arn"
        cs_api_task_def_arn = "arn:aws:ecs:us-east-1:${get_env("TF_VAR_account_id")}:task-definition/MOCK-task-def-arn"
    }
}
inputs = {
   cs_ecs_cluster_arn = dependency.ecs.outputs.cs_ecs_cluster_arn
   cs_api_task_def_arn = dependency.ecs.outputs.cs_api_task_def_arn
}
