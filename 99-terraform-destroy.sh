#!/bin/bash

cd ecs
terraform init -backend-config=config.s3.tfbackend
terraform destroy -auto-approve
cd ..

cd eks
terraform init -backend-config=config.s3.tfbackend
terraform destroy -auto-approve
cd ..