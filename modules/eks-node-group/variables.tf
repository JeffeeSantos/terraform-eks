#################################################################################
# EKS Node Group Module - Input Variables
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

variable "node_group_name" {
  description = "Nome do node group"
  type        = string
}

variable "instance_types" {
  description = "Tipos de instância EC2 (ex: [t3.medium, t3.large])"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Quantidade desejada de nós"
  type        = number
  validation {
    condition     = var.desired_size >= 1
    error_message = "Quantidade mínima de nós é 1."
  }
}

variable "min_size" {
  description = "Quantidade mínima de nós"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Quantidade máxima de nós"
  type        = number
  validation {
    condition     = var.max_size >= var.desired_size
    error_message = "max_size deve ser maior ou igual a desired_size."
  }
}

variable "subnet_ids" {
  description = "IDs das subnets privadas para o node group"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "Mínimo 1 subnet requerida."
  }
}

variable "disk_size" {
  description = "Tamanho do disco raiz em GB"
  type        = number
  default     = 100
}

variable "capacity_type" {
  description = "Tipo de capacidade (ON_DEMAND ou SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Deve ser ON_DEMAND ou SPOT."
  }
}

variable "taints" {
  description = "Taints para o node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "labels" {
  description = "Labels para os nós"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}
