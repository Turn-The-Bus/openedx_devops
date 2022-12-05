#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.2"

  required_providers {
    local = "~> 2.2"
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }

}
