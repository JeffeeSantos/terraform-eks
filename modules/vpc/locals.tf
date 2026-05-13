#################################################################################
# VPC Module - Local Values
#
# Valores calculados internamente para simplificar a configuração e evitar
# repetição de código (DRY - Don't Repeat Yourself)
#################################################################################

# Data source para obter informações da região
data "aws_region" "current" {}

# Data source para obter informações da conta AWS
data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  cluster_name = "${var.project_name}-${var.environment}"

  # Tags aplicadas a todos os recursos
  common_tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
      CreatedAt   = timestamp()
    }
  )
}
