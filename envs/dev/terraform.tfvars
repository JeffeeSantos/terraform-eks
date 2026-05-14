#################################################################################
# Development Environment - Terraform Variables (tfvars)
#
# DESENVOLVIMENTO: Configurações otimizadas para custo e rapidez
# - Instâncias mais pequenas (t3.medium)
# - Menos nós (min: 1, desired: 2, max: 3)
# - VPC com 10.0.0.0/16 (ampla para experimentação)
# - Logs retidos por 7 dias
#
# TODO: Substituir os valores com suas configurações
#################################################################################

aws_region   = "us-east-1"
environment  = "dev"
project_name = "DevOps_EKS_Trainning_Jefferson"

# Rede
vpc_cidr           = "172.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Cluster
cluster_version = "1.29"

# Node Group - Otimizado para custo em dev
node_group_instance_types = ["t3.medium"]
node_group_desired_size   = 2
node_group_min_size       = 1
node_group_max_size       = 3

# Controllers
enable_cluster_autoscaler       = true
enable_load_balancer_controller = true

# Tags comuns
tags = {
  Cost-Center = "Engineering"
  Team        = "DevOps"
  Environment = "Development"
  Project     = "trainning"
}
