# Bootstrap resources for a fresh AWS account.
#
# These are one-time, account-wide AWS-managed singletons. They are documented
# here so a clean account can reach a working state with a single `terragrunt
# apply` — no manual console clicks. Existing accounts have these imported into
# state via `terragrunt import` and `prevent_destroy` keeps them safe from
# accidental teardown.

# AWS service-linked role for ECS (Fargate control plane).
#
# AWS-managed singleton; fixed name `AWSServiceRoleForECS`; one per account.
# ECS itself assumes this role to manage cluster resources on our behalf.
# Created automatically by AWS the first time an identity with
# `iam:CreateServiceLinkedRole` on `ecs.amazonaws.com` creates an ECS cluster.
#
# Import (existing account):
#   terragrunt import aws_iam_service_linked_role.ecs \
#     arn:aws:iam::<account>:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
  description      = "AWS-managed role for ECS to manage runs-on Fargate cluster"

  lifecycle {
    prevent_destroy = true
  }
}
