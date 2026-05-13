#################################################################################
# EKS Cluster Module - IAM Roles and Policies
#################################################################################

# IAM Role para o Control Plane do EKS
resource "aws_iam_role" "eks_control_plane" {
  name = "${local.name_prefix}-eks-control-plane-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach da policy padrão do EKS ao control plane
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_control_plane.name
}

# Policy para encriptação de secrets do EKS
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_control_plane.name
}

# CloudWatch Log Group para logs do EKS Control Plane
resource "aws_cloudwatch_log_group" "eks_control_plane" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/eks/${local.name_prefix}/cluster"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-eks-logs" }
  )
}
