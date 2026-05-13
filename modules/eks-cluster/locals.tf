#################################################################################
# EKS Cluster Module - Data sources and Locals
#################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}
