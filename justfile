set export 

infraDir := "infra/modules/aws"

login-ecr: 
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 695434033664.dkr.ecr.us-east-1.amazonaws.com

port-forward:
   kubectl -n chat-stat port-forward deployment/redis 6379:6379 

kube-apply:
   kubectl apply -f k8s/deployment.yml

kube-delete:
   kubectl delete -f k8s/deployment.yml
   
build-mini:
    doppler run minikube image build -t chat-stat:local .

build-docker:
    eval $(minikube -p minikube docker-env)
    doppler run docker build -t chat-stat:local .

run:
    docker run -e REDIS_HOST="docker.for.mac.localhost" chat-stat:local

login env:
    assume-role login -p {{env}}Terraform

init dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt init \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
init-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run-all init \
    --terragrunt-working-dir {{infraDir}}

validate dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt validate \
    --terragrunt-working-dir {{infraDir}}/{{dir}}

validate-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt validate \
    --terragrunt-working-dir {{infraDir}}
    
plan dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt plan \
    --terragrunt-working-dir {{infraDir}}/{{dir}}

plan-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run-all \
    plan --terragrunt-working-dir {{infraDir}}
    
apply dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt apply \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
apply-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run-all apply \
    --terragrunt-working-dir {{infraDir}} \
    --terragrunt-non-interactive

destroy dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt destroy \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
destroy-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run-all \
    destroy --terragrunt-working-dir {{infraDir}}
    

fmt:
    doppler run \
    --name-transformer tf-var  \
    -- terraform fmt \
    --recursive

@init-module dir:
    mkdir -p {{infraDir}}/{{dir}}/env-config/us-east-1
    
    touch {{infraDir}}/{{dir}}/env-config/common.tfvars
    touch {{infraDir}}/{{dir}}/env-config/us-east-1/common.tfvars
    touch {{infraDir}}/{{dir}}/env-config/us-east-1/dev.tfvars
    touch {{infraDir}}/{{dir}}/env-config/us-east-1/prod.tfvars
    touch {{infraDir}}/{{dir}}/_outputs.tf
    touch {{infraDir}}/{{dir}}/_inputs.tf
    touch {{infraDir}}/{{dir}}/_data.tf
    touch {{infraDir}}/{{dir}}/_variables.tf
    touch {{infraDir}}/{{dir}}/{{dir}}.tf
    touch {{infraDir}}/{{dir}}/main.tf
    touch {{infraDir}}/{{dir}}/terragrunt.hcl
    
    echo 'asset_name = "{{dir}}"' >> {{infraDir}}/{{dir}}/env-config/common.tfvars
    echo 'locals {}' >> {{infraDir}}/{{dir}}/main.tf
    echo 'environment = "dev"' > {{infraDir}}/{{dir}}/env-config/us-east-1/dev.tfvars
    echo 'environment = "prod"' > {{infraDir}}/{{dir}}/env-config/us-east-1/prod.tfvars
    echo -e 'include "root" {\n\
    \tpath = find_in_parent_folders()\n\
    }' > {{infraDir}}/{{dir}}/terragrunt.hcl
    @# {{infraDir}}/{{dir}} created.
