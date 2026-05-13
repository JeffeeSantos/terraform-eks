#################################################################################
# EKS Node Group Module - Outputs
#################################################################################

output "node_group_id" {
  description = "ID do node group"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "ARN do node group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status do node group"
  value       = aws_eks_node_group.main.status
}

output "node_role_arn" {
  description = "ARN do IAM role dos nodes"
  value       = aws_iam_role.node_role.arn
}

output "node_role_name" {
  description = "Nome do IAM role dos nodes"
  value       = aws_iam_role.node_role.name
}
