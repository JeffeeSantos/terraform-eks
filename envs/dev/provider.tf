#################################################################################
# Development Environment - Provider Configuration
#
# Configura os providers AWS, Kubernetes e Helm
# Os credenciais são obtidas automaticamente de:
#   - AWS_PROFILE variável de ambiente
#   - ~/.aws/credentials
#   - IAM role (quando executado em EC2/EKS)
#################################################################################

provider "aws" {
  region = var.aws_region

  # Default tags aplicadas a todos os recursos (melhora governança)
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Provider Kubernetes - Obtém credenciais do cluster EKS
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_id]
  }
}

# Provider Helm - Configura Helm para instalar charts no cluster
provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_id]
    }
  }
}
