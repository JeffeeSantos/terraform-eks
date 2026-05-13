#################################################################################
# Terraform Development Environment Configuration
#
# Arquivo versions.tf define os requisitos de versão do Terraform e providers
# Este arquivo é compartilhado por todos os ambientes (dev, hml, prod)
#################################################################################

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
