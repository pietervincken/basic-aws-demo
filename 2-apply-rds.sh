#!/bin/bash
set -e

cd ecs-rds
terraform init -backend-config=config.s3.tfbackend
terraform apply # -auto-approve
terraform output -json > output.json

alb_fqdn=$(cat output.json| jq --raw-output '.alb_fqdn.value')

password_arn=$(cat output.json| jq --raw-output '.password_arn.value')
username=$(cat output.json| jq --raw-output '.username.value')

password=$(aws secretsmanager get-secret-value --secret-id $password_arn | jq .SecretString --raw-output | jq .password --raw-output)

if [ -z $alb_fqdn ]; then
    echo "Could not find alb_fqdn. Stopping!"
    exit 1
fi

echo "\nFQDN: "
echo "http://$alb_fqdn\n"

echo username: $username
echo password: $password

open http://$alb_fqdn

cd ..