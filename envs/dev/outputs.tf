#################################################################################
# Development Environment - Outputs
#
# Exporta informações importantes para integração com outras ferramentas
#################################################################################

output "cluster_id" {
  description = "ID do cluster EKS"
  value       = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster (para kubectl)"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificate Authority data (para autenticação)"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group do control plane"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group dos worker nodes"
  value       = module.eks_cluster.node_security_group_id
}

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Subnets públicas"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Subnets privadas"
  value       = module.vpc.private_subnets
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider (para IRSA)"
  value       = module.eks_cluster.oidc_provider_arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN da role do Cluster Autoscaler"
  value       = module.iam.cluster_autoscaler_role_arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN da role do Load Balancer Controller"
  value       = module.load_balancer.load_balancer_controller_role_arn
}
