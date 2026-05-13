#################################################################################
# Production Environment - Terraform Variables (tfvars)
#
# PRODUÇÃO: Configurações de alta disponibilidade e performance
# - Instâncias maiores (t3.xlarge ou m5.large)
# - Múltiplas AZs com high availability
# - Min: 3 nós (para HA), Desired: 5, Max: 10+
# - VPC com 192.168.0.0/16
# - Logs retidos por 90 dias
#
# ⚠️ Dados sensíveis! Não commitar com valores reais
# Use AWS Secrets Manager ou variáveis de ambiente
#################################################################################

aws_region   = "us-east-1"
environment  = "prod"
project_name = "DevOps_EKS_Trainning_Jefferson_PROD"

# Rede - Multi-AZ para alta disponibilidade
vpc_cidr           = "172.20.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Cluster - Latest stable version
cluster_version = "1.28"

# Node Group - Production-grade
node_group_instance_types = ["t3.medium"]
node_group_desired_size   = 1
node_group_min_size       = 1
node_group_max_size       = 2

# Controllers
enable_cluster_autoscaler       = true
enable_load_balancer_controller = true

# Tags - Importante para compliance e billing
tags = {
  Cost-Center        = "Production"
  Team               = "DevOps"
  Environment        = "PRD_TEST"
  Compliance         = "true"
  DataClassification = "Confidential"
  Project            = "trainning"
}
