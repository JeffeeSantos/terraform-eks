#################################################################################
# EKS Cluster Module - Security Groups
#################################################################################

# Security Group para o Control Plane do EKS
resource "aws_security_group" "eks_control_plane" {
  name        = "${local.name_prefix}-eks-control-plane-sg"
  description = "Security group para EKS control plane"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-eks-control-plane-sg" }
  )
}

# Security Group para os Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${local.name_prefix}-eks-nodes-sg"
  description = "Security group para EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_control_plane.id]
    description     = "Allow all TCP from control plane"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Allow all TCP from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-eks-nodes-sg" }
  )
}

# Data source para a VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}
