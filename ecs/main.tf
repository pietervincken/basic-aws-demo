terraform {
  backend "s3" {

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.31.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      owner      = "basic-aws-demo"
      created-by = "pieter.vincken@ordina.be"
    }
  }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = {
    owner      = "basic-aws-demo"
    created-by = "pieter.vincken@ordina.be"
  }

  name = "basicawsdemo"

  vpc_cidr = "10.0.0.0/16"
  azs = [
    data.aws_availability_zones.available.zone_ids[0],
    data.aws_availability_zones.available.zone_ids[1]
  ]

  container_port = 8080
}
