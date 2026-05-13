#################################################################################
# Production Environment - Outputs
#################################################################################

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "oidc_provider_arn" {
  value = module.eks_cluster.oidc_provider_arn
}
