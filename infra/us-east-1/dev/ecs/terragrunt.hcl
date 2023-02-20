locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment = local.environment_vars.locals.environment
  account_id  = local.account_vars.locals.account_id
}

terraform {
  source = "../../../modules/aws//ecs"
}

dependencies {
    paths = [
    "../vpc",
    "../kms",
    "../ecr",
    ]
}

dependency "vpc" {
    config_path = "../vpc/"
    /* mock_outputs_allowed_terraform_commands = ["validate"] */
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs = {
        target_group = "arn:aws:elasticloadbalancing:us-east-1:${local.account_id}:targetgroup/MOCK/0000000000000"
        private_subnets = [
            "00000000000-private-MOCK",
            "00000000000-private-MOCK",
            "00000000000-private-MOCK",
            "00000000000-private-MOCK"
        ]
        public_subnets = [
            "00000000000-public-MOCK",
            "00000000000-public-MOCK",
            "00000000000-public-MOCK",
            "00000000000-public-MOCK"
        ]
        security_group_ecs_task = "arn:sg:us-east-1:${local.account_id}:MOCK-security_group"
    }
}

dependency "ecr" {
    config_path = "../ecr/"
    mock_outputs = {
        ecr_repo_api = "MOCK-ecr-repo-api-name"
    }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
    ecr_repo_api = dependency.ecr.outputs.ecr_repo_api
    private_subnets = dependency.vpc.outputs.private_subnets
    public_subnets = dependency.vpc.outputs.public_subnets
    security_group_ecs_task = dependency.vpc.outputs.security_group_ecs_task
    target_group = dependency.vpc.outputs.target_group
}
