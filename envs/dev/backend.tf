#################################################################################
# Development Environment - Backend Configuration
#
# Define o backend S3 remoto para armazenar o estado do Terraform
# - Bucket: armazena o arquivo de estado
# - Key: caminho do arquivo dentro do bucket
# - DynamoDB: lock para prevenir execuções simultâneas
#
# ⚠️ IMPORTANTE: Configure manualmente as informações do seu backend S3:
#    1. Crie um bucket S3 com versionamento habilitado
#    2. Crie uma tabela DynamoDB com chave primária "LockID"
#    3. Substitua os valores abaixo
#################################################################################

terraform {
  backend "s3" {
    # SUBSTITUIR: Nome do seu bucket S3
    bucket = "seu-bucket-terraform-state"

    # Chave/caminho do arquivo de estado por ambiente
    key = "terraform-eks/dev/terraform.tfstate"

    # Região onde o bucket S3 está localizado
    region = "us-east-1"

    # SUBSTITUIR: Nome da sua tabela DynamoDB
    dynamodb_table = "terraform-state-lock"

    # Encriptação do estado em repouso
    encrypt = true
  }
}
