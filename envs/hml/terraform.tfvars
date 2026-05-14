#################################################################################
# Staging Environment - Terraform Variables (tfvars)
#
# HOMOLOGAÇÃO: Configurações mais robustas, simulando produção
# - Instâncias médias (t3.large)
# - Mais nós para teste de escalabilidade (min: 2, desired: 3, max: 5)
# - VPC com 172.16.0.0/16
# - Logs retidos por 30 dias
#################################################################################

aws_region   = "us-east-1"
environment  = "hml"
project_name = "DevOps_EKS_Trainning_Jefferson"

# Rede
vpc_cidr           = "172.30.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Cluster
cluster_version = "1.29"

# Node Group - Balanced para hml
node_group_instance_types = ["t3.medium"]
node_group_desired_size   = 0
node_group_min_size       = 0
node_group_max_size       = 0

# Controllers
enable_cluster_autoscaler       = true
enable_load_balancer_controller = true

# Tags
tags = {
  Cost-Center = "Engineering"
  Team        = "DevOps"
  Environment = "Staging"
  Project     = "trainning"
}
