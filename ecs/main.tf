terraform {
  backend "s3" {

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.83.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      owner      = var.user_email
      project    = var.project_name
    }
  }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = {
    owner      = var.user_email
    project    = var.project_name
  }

  name = var.project_name

  vpc_cidr = "10.0.0.0/16"
  azs = [
    data.aws_availability_zones.available.zone_ids[0],
    data.aws_availability_zones.available.zone_ids[1]
  ]

  container_port = 8080
}
