skip = true
include "root" {
  path = find_in_parent_folders()
}

dependency "ecr" {
    config_path = "../ecr"
    mock_outputs = {
        ecr_repo_api = "MOCK-ecr-repo-api-name"
    }
}

inputs = {
    ecr_repo_api = dependency.ecr.outputs.ecr_repo_api
    # private_subnets = dependency.vpc.outputs.private_subnets
    # public_subnets = dependency.vpc.outputs.public_subnets
    # security_group_ecs_task = dependency.vpc.outputs.security_group_ecs_task
    # target_group = dependency.vpc.outputs.target_group
}
