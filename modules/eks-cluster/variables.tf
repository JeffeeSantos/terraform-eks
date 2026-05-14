#################################################################################
# EKS Cluster Module - Input Variables
#################################################################################

variable "environment" {
  description = "Environment name (dev, hml, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment deve ser dev, hml ou prod."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes (ex: 1.29)"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID da VPC onde o cluster será criado"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas (mínimo 2)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Mínimo 2 subnets públicas requeridas."
  }
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas (mínimo 2)"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Mínimo 2 subnets privadas requeridas."
  }
}

variable "enable_logging" {
  description = "Habilitar logging de controle plane"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Retenção de logs do control plane em dias"
  type        = number
  default     = 7
}

variable "enable_cluster_autoscaler" {
  description = "Preparar IAM para Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Instalar EBS CSI Driver"
  type        = bool
  default     = true
}

variable "enable_efs_csi_driver" {
  description = "Instalar EFS CSI Driver"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
