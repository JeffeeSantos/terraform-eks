#################################################################################
# IAM Module - Outputs
#################################################################################

output "cluster_autoscaler_role_arn" {
  description = "ARN da role do Cluster Autoscaler"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

output "load_balancer_controller_role_arn" {
  description = "ARN da role do Load Balancer Controller"
  value       = var.enable_load_balancer_controller ? aws_iam_role.load_balancer_controller[0].arn : null
}

output "external_dns_role_arn" {
  description = "ARN da role do External DNS"
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}
