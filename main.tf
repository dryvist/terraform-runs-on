module "runs_on" {
  source  = "runs-on/runs-on/aws//modules/flex"
  version = ">= 3.0.8, < 4.0.0"

  # Required. license_key and OIDC role ARN are fetched at runtime from Doppler (see CLAUDE.md).
  github_organization = var.github_organization
  license_key         = var.license_key
  email               = var.email
  vpc_id              = aws_vpc.runs_on.id
  public_subnet_ids   = aws_subnet.public[*].id

  # Required in v3 (flex submodule)
  app_size             = var.app_size
  app_budget_daily_usd = var.app_budget_daily_usd

  # v3 ingress hardening — managed WAF + admin-route gating
  enable_waf          = var.enable_waf
  enable_admin_routes = var.enable_admin_routes

  # v3 optional runner capability — Bedrock model access from CI
  enable_bedrock = var.enable_bedrock

  # Non-default overrides
  logger_level        = "debug"
  log_retention_days  = 30
  cost_allocation_tag = "runs-on"
  tags                = local.common_tags

  # OTEL — Cribl.Cloud Free endpoint
  otel_exporter_endpoint = var.otel_exporter_endpoint
  otel_exporter_headers  = var.otel_exporter_headers

  # Alert routing — email is always set, Slack webhook is optional
  alert_slack_webhook_url = var.alert_slack_webhook_url
}
