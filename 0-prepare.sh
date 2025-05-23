#!/bin/bash

if [ -z $AWS_REGION ]; then
    echo "Could not find AWS_REGION. Stopping!"
    exit 1
fi

if [ -z $PROJECT_NAME ]; then
    echo "Could not find PROJECT_NAME. Stopping!"
    exit 1
fi

if [ -z $USER_EMAIL ]; then
    echo "Could not find USER_EMAIL. Stopping!"
    exit 1
fi

aws cloudformation deploy \
    --template-file cloudformation/prepare-tf.yaml \
    --stack-name $PROJECT_NAME \
    --tags owner=$USER_EMAIL project=$PROJECT_NAME \
    --parameter-overrides "ParameterKey=ProjectName,ParameterValue=$PROJECT_NAME ParameterKey=Email,ParameterValue=$USER_EMAIL"

output=$(aws cloudformation describe-stacks --stack-name $PROJECT_NAME)
bucketname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="bucketname") | .OutputValue')
lockname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="locktable") | .OutputValue')

rm ecs/config.s3.tfbackend || true
rm ecs-rds/config.s3.tfbackend || true
rm eks/config.s3.tfbackend || true

echo "bucket                = \"$bucketname\""         >> ecs/config.s3.tfbackend
echo "dynamodb_table        = \"$lockname\""           >> ecs/config.s3.tfbackend
echo "region                = \"$AWS_REGION\""         >> ecs/config.s3.tfbackend
echo 'key                   = "terraform-ecs.tfstate"' >> ecs/config.s3.tfbackend

echo "bucket                = \"$bucketname\""         >> ecs-rds/config.s3.tfbackend
echo "dynamodb_table        = \"$lockname\""           >> ecs-rds/config.s3.tfbackend
echo "region                = \"$AWS_REGION\""         >> ecs-rds/config.s3.tfbackend
echo 'key                   = "terraform-ecs.tfstate"' >> ecs-rds/config.s3.tfbackend

echo "bucket                = \"$bucketname\""             >> eks/config.s3.tfbackend
echo "dynamodb_table        = \"$lockname\""               >> eks/config.s3.tfbackend
echo "region                = \"$AWS_REGION\""             >> eks/config.s3.tfbackend
echo 'key                   = "terraform-eks.tfstate"' >> eks/config.s3.tfbackend