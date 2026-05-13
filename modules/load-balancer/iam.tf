#################################################################################
# Load Balancer Module - IAM Role for AWS Load Balancer Controller
#################################################################################

# IAM Role para o AWS Load Balancer Controller
resource "aws_iam_role" "load_balancer_controller" {
  name = "${local.name_prefix}-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Política detalhada para ALB/NLB
resource "aws_iam_role_policy" "load_balancer_controller" {
  name   = "${local.name_prefix}-load-balancer-controller-policy"
  role   = aws_iam_role.load_balancer_controller.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elbv2:AddListenerCertificates",
          "elbv2:AddTags",
          "elbv2:CreateListener",
          "elbv2:CreateLoadBalancer",
          "elbv2:CreateTargetGroup",
          "elbv2:DeleteListener",
          "elbv2:DeleteLoadBalancer",
          "elbv2:DeleteTargetGroup",
          "elbv2:DeregisterTargets",
          "elbv2:DescribeListenerCertificates",
          "elbv2:DescribeListeners",
          "elbv2:DescribeLoadBalancerAttributes",
          "elbv2:DescribeLoadBalancers",
          "elbv2:DescribeTargetGroupAttributes",
          "elbv2:DescribeTargetGroups",
          "elbv2:DescribeTags",
          "elbv2:ModifyListener",
          "elbv2:ModifyLoadBalancerAttributes",
          "elbv2:ModifyTargetGroup",
          "elbv2:ModifyTargetGroupAttributes",
          "elbv2:RegisterTargets",
          "elbv2:RemoveListenerCertificates",
          "elbv2:RemoveTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstances",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners"
        ]
        Resource = "*"
      }
    ]
  })
}
