#################################################################################
# EKS Cluster Module - EKS Cluster Resource
#
# Cria o cluster EKS com as configurações de logging e network
#################################################################################

resource "aws_eks_cluster" "main" {
  name     = local.name_prefix
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_control_plane.arn

  enabled_cluster_log_types = var.enable_logging ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ] : []

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    security_group_ids      = [aws_security_group.eks_control_plane.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    local.common_tags,
    { Name = local.name_prefix }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_cloudwatch_log_group.eks_control_plane,
    aws_security_group.eks_control_plane
  ]
}

# VPC CNI Add-on (suporta rede, pode ser paralelo)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version
  service_account_role_arn = aws_iam_role.vpc_cni.arn

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# CoreDNS Add-on (paralelo com VPC CNI e kube-proxy)
resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "coredns"
  addon_version = data.aws_eks_addon_version.coredns.version

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# kube-proxy Add-on (paralelo com VPC CNI e CoreDNS)
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy.version

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# EBS CSI Driver Add-on (paralelo, sem dependências)
resource "aws_eks_addon" "ebs_csi" {
  count                    = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi.version
  service_account_role_arn = aws_iam_role.ebs_csi[0].arn

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# EFS CSI Driver Add-on (paralelo, sem dependências)
resource "aws_eks_addon" "efs_csi" {
  count                    = var.enable_efs_csi_driver ? 1 : 0
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = data.aws_eks_addon_version.efs_csi.version
  service_account_role_arn = aws_iam_role.efs_csi[0].arn

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

resource "aws_eks_addon" "efs_csi" {
  count                    = var.enable_efs_csi_driver ? 1 : 0
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = data.aws_eks_addon_version.efs_csi.version
  service_account_role_arn = aws_iam_role.efs_csi[0].arn

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  tags = local.common_tags
}

# Data sources para versões de Add-ons
data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

data "aws_eks_addon_version" "efs_csi" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}
