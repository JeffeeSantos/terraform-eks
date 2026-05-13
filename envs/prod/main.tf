#################################################################################
# Production Environment - Main Configuration
#################################################################################

module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  project_name       = var.project_name
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = true
  enable_flow_logs   = true

  tags = var.tags
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  environment           = var.environment
  project_name          = var.project_name
  cluster_version       = var.cluster_version
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnets
  private_subnet_ids    = module.vpc.private_subnets
  enable_logging        = true
  log_retention_in_days = 90
  enable_ebs_csi_driver = true
  enable_efs_csi_driver = true

  tags = var.tags

  depends_on = [module.vpc]
}

module "iam" {
  source = "../../modules/iam"

  environment                     = var.environment
  project_name                    = var.project_name
  oidc_provider_arn               = module.eks_cluster.oidc_provider_arn
  oidc_provider_url               = module.eks_cluster.oidc_provider_url
  enable_cluster_autoscaler       = var.enable_cluster_autoscaler
  enable_load_balancer_controller = var.enable_load_balancer_controller

  tags = var.tags

  depends_on = [module.eks_cluster]
}

module "node_group" {
  source = "../../modules/eks-node-group"

  environment     = var.environment
  project_name    = var.project_name
  cluster_name    = module.eks_cluster.cluster_id
  node_group_name = "general"
  instance_types  = var.node_group_instance_types
  desired_size    = var.node_group_desired_size
  min_size        = var.node_group_min_size
  max_size        = var.node_group_max_size
  subnet_ids      = module.vpc.private_subnets
  capacity_type   = "ON_DEMAND"
  disk_size       = 150

  labels = {
    "node-type"  = "general"
    "production" = "true"
  }

  tags = var.tags

  depends_on = [module.eks_cluster]
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  environment       = var.environment
  project_name      = var.project_name
  cluster_name      = module.eks_cluster.cluster_id
  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_provider_url = module.eks_cluster.oidc_provider_url

  tags = var.tags

  depends_on = [module.eks_cluster]
}
