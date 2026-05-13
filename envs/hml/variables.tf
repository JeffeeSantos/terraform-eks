#################################################################################
# Staging Environment - Variables
#################################################################################

variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
}

variable "node_group_instance_types" {
  description = "Tipos de instância"
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
  description = "Habilitar Load Balancer Controller"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
