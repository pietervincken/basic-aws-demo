#!/bin/sh

if [ -z $PROJECT_NAME ]; then
    echo "Could not find PROJECT_NAME. Stopping!"
    exit 1
fi

output=$(aws cloudformation describe-stacks --stack-name $PROJECT_NAME)
bucketname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="bucketname") | .OutputValue')

# Delete all records in bucket, otherwise delete will fail
# TF leaves "empty" tf statefile 
aws s3 rm s3://$bucketname --recursive

aws cloudformation delete-stack \
    --stack-name $PROJECT_NAME