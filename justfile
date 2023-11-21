set export 

infraDir := "infra/modules/aws"

port-forward:
   kubectl -n chat-stat port-forward deployment/redis 6379:6379 

kube-apply:
   kubectl apply -f k8s/deployment.yml

kube-delete:
   kubectl delete -f k8s/deployment.yml
   
build-mini:
    minikube image build -t chat-stat:local .

build-docker:
    eval $(minikube -p minikube docker-env)
    docker build -t chat-stat:local .

build-docker-test:
    docker build \
    --build-arg="TWITCH_CLIENT_ID=$TWITCH_CLIENT_ID" \
    --build-arg="TWITCH_CLIENT_SECRET=$TWITCH_CLIENT_SECRET" \
    -t chat-stat:local .

run:
    docker run -e REDIS_HOST="docker.for.mac.localhost" chat-stat:local

login env:
    assume-role login -p {{env}}Terraform

init dir:
    terragrunt init \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
init-all:
    terragrunt run-all init \
    --terragrunt-working-dir {{ \
    infraDir}}

validate dir:
    doppler run -- \
    terragrunt validate \
    --terragrunt-working-dir {{infraDir}}/{{dir}}

validate-all:
    doppler run -- \
    terragrunt validate \
    --terragrunt-working-dir {{infraDir}}
    
plan dir:
    doppler run -- \
    terragrunt plan \
    --terragrunt-working-dir {{infraDir}}/{{dir}}

plan-all:
    doppler run -- \
    terragrunt run-all \
    plan --terragrunt-working-dir {{infraDir}}
    
apply dir:
    doppler run -- \
    terragrunt apply \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
apply-all:
    doppler run -- \
    terragrunt run-all \
    apply --terragrunt-working-dir {{infraDir}}

destroy dir:
    doppler run -- \
    terragrunt destroy \
    --terragrunt-working-dir {{infraDir}}/{{dir}}
    
destroy-all:
    doppler run -- \
    terragrunt run-all \
    destroy --terragrunt-working-dir {{infraDir}}

fmt:
    doppler run -- \
    terraform fmt \
    --recursive
