set export 

infraDir := "infra/modules/aws"

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
    -- terragrunt run-all \
    apply --terragrunt-working-dir {{infraDir}}

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
