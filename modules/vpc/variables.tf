#################################################################################
# VPC Module - Input Variables
#
# Define todas as variáveis de entrada para o módulo VPC
# Permite criação de VPCs com diferentes configurações por ambiente
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
  description = "Nome do projeto para nomenclatura de recursos"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "Project name deve ter entre 1 e 32 caracteres."
  }
}

variable "cidr_block" {
  description = "CIDR block principal da VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "CIDR block inválido."
  }
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade (recomendado: mínimo 2)"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 4
    error_message = "Informe entre 2 e 4 zonas de disponibilidade."
  }
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para acesso à internet de subnets privadas"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Habilitar VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Habilitar VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_in_days" {
  description = "Retenção de VPC Flow Logs em dias"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags comuns a serem aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
