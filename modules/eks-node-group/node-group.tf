#################################################################################
# EKS Node Group Module - Managed Node Group
#################################################################################

resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${var.node_group_name}"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids
  version         = null  # Usar versão do cluster

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size

  # Tags para os nós
  tags = merge(
    local.common_tags,
    { Name = "${var.cluster_name}-${var.node_group_name}" }
  )

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = merge(
    var.labels,
    {
      "node-group" = var.node_group_name
    }
  )

  # Aguarda o cluster estar pronto antes de criar o node group
  depends_on = []

  # Lifecycle para update gradual
  lifecycle {
    create_before_destroy = true
  }
}
