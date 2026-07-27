locals {
  name_prefix = "${var.project_name}-${var.student_name}"

  oidc_provider_url_without_https = replace(
    var.oidc_provider_url,
    "https://",
    ""
  )

  create_route53_roles = var.public_zone_arn != null && var.public_zone_arn != ""
}

# Current AWS partition
data "aws_partition" "current" {}

# AWS Load Balancer Controller IAM Policy
# -------------------------------------------------------------------
resource "aws_iam_policy" "alb_controller" {
  name        = "${local.name_prefix}-aws-load-balancer-controller"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role" "alb_controller" {
  name = "${local.name_prefix}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_url_without_https}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url_without_https}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-alb-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}


# ExternalDNS IAM Policy
# -------------------------------------------------------------------
resource "aws_iam_policy" "externaldns" {
  count = local.create_route53_roles ? 1 : 0

  name        = "${local.name_prefix}-externaldns"
  description = "IAM policy for ExternalDNS to manage Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets"
        ]

        Resource = var.public_zone_arn
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

# ExternalDNS IRSA Role
resource "aws_iam_role" "externaldns" {
  count = local.create_route53_roles ? 1 : 0

  name = "${local.name_prefix}-externaldns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_url_without_https}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url_without_https}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-externaldns-role"
  }
}

resource "aws_iam_role_policy_attachment" "externaldns" {
  count = local.create_route53_roles ? 1 : 0

  role       = aws_iam_role.externaldns[0].name
  policy_arn = aws_iam_policy.externaldns[0].arn
}

# cert-manager IAM Policy for Route53 DNS-01 Challenge
# -------------------------------------------------------------------
resource "aws_iam_policy" "cert_manager" {
  count = local.create_route53_roles ? 1 : 0

  name        = "${local.name_prefix}-cert-manager"
  description = "IAM policy for cert-manager DNS01 validation using Route53"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "route53:GetChange"
        ]

        Resource = "arn:${data.aws_partition.current.partition}:route53:::change/*"
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]

        Resource = var.public_zone_arn
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName"
        ]

        Resource = "*"
      }
    ]
  })
}

# cert-manager IRSA Role
resource "aws_iam_role" "cert_manager" {
  count = local.create_route53_roles ? 1 : 0

  name = "${local.name_prefix}-cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_url_without_https}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url_without_https}:sub" = "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-cert-manager-role"
  }
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  count = local.create_route53_roles ? 1 : 0

  role       = aws_iam_role.cert_manager[0].name
  policy_arn = aws_iam_policy.cert_manager[0].arn
}

# External Secrets Operator IAM Policy
# -------------------------------------------------------------------
resource "aws_iam_policy" "external_secrets" {
  name        = "${local.name_prefix}-external-secrets"
  description = "IAM policy for External Secrets Operator to read AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = "*"
      }
    ]
  })
}

# External Secrets Operator IRSA Role
resource "aws_iam_role" "external_secrets" {
  name = "${local.name_prefix}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_url_without_https}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url_without_https}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-external-secrets-role"
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# Cluster Autoscaler Policy
# -------------------------------------------------------------------
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${local.name_prefix}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "eks:DescribeNodegroup"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]

        Resource = "*"
      }
    ]
  })
}

# Cluster Autoscaler IRSA Role
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${local.name_prefix}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = var.oidc_provider_arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "${local.oidc_provider_url_without_https}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider_url_without_https}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
