#################################################################################
# VPC Module - Versioning Configuration
# 
# Definição de versões dos providers e terraform necessários para o módulo VPC
# Mantém compatibilidade com a versão definida na root
#################################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
