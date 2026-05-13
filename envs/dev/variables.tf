#################################################################################
# Development Environment - Variables
#
# Define as variáveis de entrada para o ambiente de desenvolvimento
# Os valores são fornecidos através do arquivo terraform.tfvars
#################################################################################

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, hml, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado na nomenclatura de recursos)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade para a VPC"
  type        = list(string)
}

variable "cluster_version" {
  description = "Versão do Kubernetes do cluster EKS"
  type        = string
}

variable "node_group_instance_types" {
  description = "Tipos de instância para o node group"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Quantidade desejada de nós"
  type        = number
}

variable "node_group_min_size" {
  description = "Quantidade mínima de nós"
  type        = number
}

variable "node_group_max_size" {
  description = "Quantidade máxima de nós"
  type        = number
}

variable "enable_cluster_autoscaler" {
  description = "Habilitar Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_load_balancer_controller" {
  description = "Habilitar AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default     = {}
}
