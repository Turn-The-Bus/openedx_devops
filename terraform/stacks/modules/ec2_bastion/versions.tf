#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14"
    }
  }
}
