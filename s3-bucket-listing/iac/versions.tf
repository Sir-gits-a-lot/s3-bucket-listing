provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.9.4"

  required_providers {
    kubernetes = {
      source  = "registry.terraform.io/hashicorp/kubernetes"
      version = "2.31.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }
}