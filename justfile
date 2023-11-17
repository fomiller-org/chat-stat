infraDir := "infra/us-east-1/"

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

run:
    docker run -e REDIS_HOST="docker.for.mac.localhost" chat-stat:local

login env:
    assume-role login -p {{env}}Terraform

plan env dir:
    terragrunt plan --terragrunt-working-dir {{infraDir}}{{env}}/{{dir}}

plan-all env:
    terragrunt run-all plan --terragrunt-working-dir {{infraDir}}{{env}}
    
init env dir:
    terragrunt init --terragrunt-working-dir {{infraDir}}{{env}}/{{dir}}
    
init-all env:
    terragrunt run-all init --terragrunt-working-dir {{infraDir}}{{env}}

fmt:
    terraform fmt --recursive

validate env:
    terragrunt run-all validate --terragrunt-working-dir {{infraDir}}{{env}}
