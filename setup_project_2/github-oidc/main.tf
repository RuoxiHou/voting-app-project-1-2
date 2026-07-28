# One-time bootstrap: run this stack locally (with my own AWS credentials),
# NOT from GitHub Actions. It creates the trust relationship GitHub Actions needs before it can assume any role in this account.

data "aws_caller_identity" "current" {}

# GitHub's OIDC token issuer certificate thumbprint.
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# IAM role assumable only by workflow runs from the allowed branches of the specified GitHub repo.
resource "aws_iam_role" "github_actions" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = local.oidc_provider_arn
        }

        # aws-actions/configure-aws-credentials attaches GitHub context values
        # (repo, workflow, actor, branch, etc.) as role session tags by default.
        # Without sts:TagSession also allowed, AWS rejects the WHOLE
        # AssumeRoleWithWebIdentity call with a generic "Not authorized" error.
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "sts:TagSession"
        ]

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for branch in var.allowed_branches :
              "repo:${var.github_repo}:ref:refs/heads/${branch}"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = var.role_name
  }
}

# Broad permissions since this role provisions VPC/EKS/RDS/IAM/S3/Route53/SecretsManager across the whole pipeline.
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
