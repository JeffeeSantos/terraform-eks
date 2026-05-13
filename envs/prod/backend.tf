#################################################################################
# Production Environment - Backend Configuration
#
# ⚠️ PRODUÇÃO: Esta configuração é critica!
# - Use um bucket S3 separado para produção
# - Habilite versionamento e encriptação
# - Configure replicação para DR
# - Restrinja acesso apenas a credenciais de produção
#################################################################################

terraform {
  backend "s3" {
    bucket = "terraform-trainning-jefferson-s3"
    key    = "terraform-eks/prod/terraform.tfstate"
    region = "us-east-1"
    #dynamodb_table = "terraform-state-lock-prod"
    encrypt = true
  }
}
