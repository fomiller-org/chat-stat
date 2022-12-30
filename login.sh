#!/bin/bash

apt-get update
apt-get install git

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile saml
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile saml

