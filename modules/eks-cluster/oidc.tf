#################################################################################
# EKS Cluster Module - OIDC Provider (para Workload Identity)
#
# O OIDC Provider permite que aplicações no Kubernetes assumam roles IAM
# da AWS sem a necessidade de usar chaves de acesso (mais seguro)
#################################################################################

# Extrai o thumbprint do certificado OIDC
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# IAM OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-eks-oidc" }
  )
}

# Extrai o ARN do OIDC Provider
locals {
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_provider_url = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}
