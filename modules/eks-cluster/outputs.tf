#################################################################################
# EKS Cluster Module - Outputs
#################################################################################

output "cluster_id" {
  description = "Nome/ID do cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint do API Server do Kubernetes"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "ID do security group do control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "node_security_group_id" {
  description = "ID do security group dos worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL do OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "cluster_version" {
  description = "Versão do Kubernetes"
  value       = aws_eks_cluster.main.version
}
