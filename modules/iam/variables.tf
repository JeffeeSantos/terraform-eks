#################################################################################
# IAM Module - Input Variables
#################################################################################

variable "environment" {
  description = "Environment name (dev, hml, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN do OIDC Provider do EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL do OIDC Provider do EKS (sem https://)"
  type        = string
}

variable "enable_cluster_autoscaler" {
  description = "Habilitar IAM para Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_load_balancer_controller" {
  description = "Habilitar IAM para AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Habilitar IAM para External DNS"
  type        = bool
  default     = false
}

variable "enable_cert_manager" {
  description = "Habilitar IAM para Cert Manager"
  type        = bool
  default     = false
}

variable "enable_ebs_autoscaling" {
  description = "Habilitar IAM para EBS Auto Scaling"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
