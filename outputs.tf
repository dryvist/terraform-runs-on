output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC authentication"
  value       = aws_iam_role.github_actions.arn
  sensitive   = true
}

output "budget_name" {
  description = "Name of the AWS Budget"
  value       = aws_budgets_budget.runs_on.name
}

output "runs_on_ingress_url" {
  description = "Public ingress URL for the RunsOn v3 control plane. Visit /setup on first install to register the GitHub App."
  value       = module.runs_on.ingress.url
}

output "runs_on_stack" {
  description = "RunsOn Flex stack metadata (cluster, runtime, queues, alerts)."
  value       = module.runs_on.stack
}
