# basic-aws-demo

This is a basic cloud demo. 
It showcases AWS Elastic Container Service (ECS) and Elastic Kubernetes Service (EKS)

## How it works?

There are 4 demos in total, 2 for ECS and 2 for EKS.
The scripts are expected to be executed in numerical order. 

### .env

A dot-env file is required for this demo to run. Fill it with the following contents: 

``` bash
export AWS_PROFILE="nameofprofiletouse" # this should be the profile that's used to deploy the demo setup
export AWS_REGION="eu-west-1" # This should be the region that's used to deploy all resources to. 
```

### 0-prepare.sh

This is a utility script that will create a Cloudformation stack with the required S3 and DynamoDB resources to use for the Terraform state. 
It also creates the required files for that information to be passed to the other scripts. 

### 1-apply-ecs.sh

This script creates a demo ECS setup. 
It launches all required resources to host a container in ECS and makes it usable from the public internet.
After the Terraform changes have been applied, it will automatically launch the application in the default web browser.

### 2-apply-ecs-rds.sh

This script launches the 2nd ECS demo. 
This demo contains a setup with an RDS PostgreSQL database, a Secrets Manager Secret and an ECS container PhpPgAdmin. 
After the demo is applied, the browser will launch the website to PhPPgAdmin and the username and password of the database will be shown in the output of the command. 
In this demo, you can show that it's possible to set up a database and connect to it from a service within AWS without exposing it to the public world.

### 3-apply-cluster.sh

This utility script creates an EKS cluster.
It is a preparation setup for the 4th script.
Launch this while explaining the use case, as it might take 5-10 minutes to spin up the cluster.

### 4-deploy-demos.sh

This launches the 2 Kubernetes demos that are available in this repo. 

The first one is a simple hello Kubernetes application. 
This demo can be used to show how Kubernetes works (through k9s). 
Scaling out the hello-world application clearly shows that multiple pods are used (Tip: use CURL if the session is sticky in Chrome or Safari)
Restarting the service is another good demo. 

The second demo shows that Kubernetes can also be used for complex workloads with a lot of different components. 
This demo uses a version of the Google Microservices demo. 

After deploying the applications, a browser will automatically be opened for both demos. 

### 99-terraform-destroy.sh

This is a utility cleanup script. 
It cleans up both the cluster and the ECS demo.
**All data in the database and cluster WILL BE LOST when executing this**

### 100-destroy.sh

This final utility script is the inverse of the first `0-prepare.sh` script. 
It removes the cloudformation stack resulting in the cleanup of the S3 and DynamoDB resources used for storing the Terraform state.