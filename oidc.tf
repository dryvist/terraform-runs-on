# GitHub Actions OIDC Provider
# One-per-account resource. If another repo creates one later, import it:
#   terraform import aws_iam_openid_connect_provider.github <arn>
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  tags = local.common_tags
}

# IAM Role for GitHub Actions OIDC authentication
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_organization}/terraform-runs-on:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "terraform-runs-on-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = local.common_tags
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_permissions" {
  # Terraform state bucket
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
    ]
    resources = [
      "arn:aws:s3:::*-tfstate-terraform-runs-on",
      "arn:aws:s3:::*-tfstate-terraform-runs-on/*",
    ]
  }

  # Terraform state lock table
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/*-tflocks-terraform-runs-on"]
  }

  # RunsOn CloudFormation stacks
  statement {
    effect    = "Allow"
    actions   = ["cloudformation:*"]
    resources = ["arn:aws:cloudformation:*:${data.aws_caller_identity.current.account_id}:stack/runs-on*/*"]
  }

  # EC2/VPC and App Runner — must remain * (AWS requires it for RunInstances, Describe*)
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "apprunner:*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  # IAM scoped to runs-on* and terraform-runs-on* resources only.
  # The terraform-runs-on-github-actions role itself is managed by this
  # terraform project, so the role needs to be able to refresh its own
  # state (iam:GetRole, iam:GetRolePolicy, etc.) during plan.
  statement {
    effect = "Allow"
    actions = [
      "iam:*",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/runs-on*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/runs-on*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/runs-on*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform-runs-on*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/terraform-runs-on*",
    ]
  }

  # S3 scoped to runs-on module buckets (state bucket handled above)
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::runs-on-*",
      "arn:aws:s3:::runs-on-*/*",
    ]
  }

  # DynamoDB scoped to runs-on module tables (state lock handled above)
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/runs-on-*",
    ]
  }

  # SQS scoped to runs-on queues
  statement {
    effect = "Allow"
    actions = [
      "sqs:*",
    ]
    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:runs-on-*",
    ]
  }

  # Logs, CloudWatch, Budgets, SNS — Describe/List actions require * resources
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
      "cloudwatch:*",
      "budgets:*",
      "sns:*",
    ]
    resources = ["*"]
  }

  # EventBridge rules — RunsOn spot interruption rule and cost-allocation tag rule
  # are created by the RunsOn CloudFormation stack; terraform refreshes their
  # state during plan to detect drift.
  statement {
    effect    = "Allow"
    actions   = ["events:*"]
    resources = ["arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/runs-on*"]
  }

  # EventBridge Scheduler — runs-on-cost-report and runs-on-cost-allocation-tag
  # schedules are created by the RunsOn CloudFormation stack. Scoped to the
  # default schedule group's runs-on* schedules.
  statement {
    effect  = "Allow"
    actions = ["scheduler:*"]
    resources = [
      "arn:aws:scheduler:*:${data.aws_caller_identity.current.account_id}:schedule/default/runs-on*",
    ]
  }

  # Secrets Manager — /runs-on/* secrets hold the RunsOn stack config. Scoped
  # to the /runs-on/ path prefix so the role cannot read unrelated secrets.
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:*"]
    resources = [
      "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:/runs-on/*",
    ]
  }

  # Resource Groups — runs-on-ec2-instances is a tag-based group used by the
  # RunsOn cost dashboards. Scoped to runs-on* groups only.
  statement {
    effect    = "Allow"
    actions   = ["resource-groups:*"]
    resources = ["arn:aws:resource-groups:*:${data.aws_caller_identity.current.account_id}:group/runs-on*"]
  }

  # IAM OIDC provider — managed directly by terraform (not via CloudFormation),
  # so the role needs full CRUD on the specific provider ARN. The wider iam:*
  # statement above is scoped to runs-on* resources and does NOT cover the
  # oidc-provider/* path.
  statement {
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviderTags",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
    ]
  }

  # Lambda — v3 control plane deploys runs-on-public-ingress, runs-on-stack-config-materializer,
  # runs-on-github-runner-cache-refresh. Scoped to runs-on* function names; the trailing
  # :* variant covers versions and aliases.
  statement {
    effect  = "Allow"
    actions = ["lambda:*"]
    resources = [
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:runs-on*",
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:runs-on*:*",
    ]
  }

  # API Gateway — v3 public ingress is a REST API. The tags resource is a separate ARN
  # path and apigateway:PUT/POST/DELETE/etc. all need /tags/* coverage to attach the
  # common_tags set.
  statement {
    effect  = "Allow"
    actions = ["apigateway:*"]
    resources = [
      "arn:aws:apigateway:*::/restapis*",
      "arn:aws:apigateway:*::/tags/*",
    ]
  }

  # SSM Parameter Store — v3 publishes /runs-on/license/status and other state under
  # the /runs-on/ namespace. Split into two statements: Describe/List actions operate
  # at the service level (require Resource: *) and CRUD operates on specific parameter
  # ARNs. Same pattern as the logs/cloudwatch statements above.
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParametersByPath",
      "ssm:ListTagsForResource",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
      "ssm:AddTagsToResource",
      "ssm:RemoveTagsFromResource",
      "ssm:LabelParameterVersion",
    ]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/runs-on/*",
    ]
  }

  # ECS — v3 control plane runs on Fargate. Cluster is named "runs-on"; task
  # definitions and services are prefixed "runs-on-". Describe* actions also
  # included here because they DO support resource-level scoping (AWS
  # service-authorization reference: ECS Describe* operations all carry a
  # specific resource type).
  statement {
    effect  = "Allow"
    actions = ["ecs:*"]
    resources = [
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/runs-on",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:cluster/runs-on-*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/runs-on/*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/runs-on-*/*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task-definition/runs-on-*:*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:container-instance/runs-on/*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:container-instance/runs-on-*/*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/runs-on/*",
      "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:task/runs-on-*/*",
    ]
  }
  # ECS service-level actions — these have no resource-level scoping per AWS
  # service-authorization reference (List*, RegisterTaskDefinition). They are
  # bounded by the calling principal being this CI role only.
  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:ListClusters",
      "ecs:ListServices",
      "ecs:ListTaskDefinitionFamilies",
    ]
    resources = ["*"]
  }

  # ECS service-linked role — managed via aws_iam_service_linked_role.ecs in
  # bootstrap.tf. iam:GetRole is needed for terraform refresh; iam:CreateServiceLinkedRole
  # lets a fresh AWS account create the SLR on first apply (existing accounts have
  # it imported into state). Condition limits create to the ECS SLR only.
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:CreateServiceLinkedRole",
      "iam:ListRoleTags",
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:AWSServiceName"
      values   = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "terraform-runs-on-permissions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}
