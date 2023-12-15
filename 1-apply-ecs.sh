#!/bin/bash
set -e

cd ecs
terraform init -backend-config=config.s3.tfbackend
terraform apply # -auto-approve
terraform output -json > output.json

alb_fqdn=$(cat output.json| jq --raw-output '.alb_fqdn.value')

if [ -z $alb_fqdn ]; then
    echo "Could not find alb_fqdn. Stopping!"
    exit 1
fi

echo "\nFQDN: "
echo "http://$alb_fqdn\n"

open http://$alb_fqdn

cd ..