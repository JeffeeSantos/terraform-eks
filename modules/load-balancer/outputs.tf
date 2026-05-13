#################################################################################
# Load Balancer Module - Outputs
#################################################################################

output "load_balancer_controller_role_arn" {
  description = "ARN da role do Load Balancer Controller"
  value       = aws_iam_role.load_balancer_controller.arn
}

output "load_balancer_controller_role_name" {
  description = "Nome da role do Load Balancer Controller"
  value       = aws_iam_role.load_balancer_controller.name
}
