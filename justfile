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

login-test:
   export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
       $(aws sts assume-role \
       --role-arn arn:aws:iam::695434033664:role/AWSTERRAFORM \
       --role-session-name local \
       --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
       --output text))

init dir:
    terragrunt init --terragrunt-working-dir {{infraDir}}/{{dir}}
    
init-all:
    terragrunt run-all init --terragrunt-working-dir {{infraDir}}

validate dir:
    terragrunt validate --terragrunt-working-dir {{infraDir}}/{{dir}}

validate-all:
    terragrunt validate --terragrunt-working-dir {{infraDir}}
    
plan dir:
    terragrunt plan --terragrunt-working-dir {{infraDir}}/{{dir}}

plan-all:
    terragrunt run-all plan --terragrunt-working-dir {{infraDir}}
    
apply dir:
    terragrunt apply --terragrunt-working-dir {{infraDir}}/{{dir}}
    
apply-all:
    terragrunt run-all apply --terragrunt-working-dir {{infraDir}}

destroy dir:
    terragrunt destroy --terragrunt-working-dir {{infraDir}}/{{dir}}
    
destroy-all:
    terragrunt run-all destroy --terragrunt-working-dir {{infraDir}}

fmt:
    terraform fmt --recursive
