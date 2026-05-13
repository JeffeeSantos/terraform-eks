#################################################################################
# Load Balancer Module - Input Variables
#################################################################################

variable "environment" {
  description = "Environment name (dev, hml, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN do OIDC Provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL do OIDC Provider (sem https://)"
  type        = string
}

variable "helm_chart_version" {
  description = "Versão do Helm Chart do AWS Load Balancer Controller"
  type        = string
  default     = "2.6.0"
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
