variable "github_organization" {
  description = "GitHub organization or username"
  type        = string
  default     = "JacobPEvans"
}

variable "license_key" {
  description = "RunsOn license key"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email for SNS alert subscription (cost reports, error notifications). Must be a real inbox that can receive AWS SNS confirmation messages — GitHub noreply addresses silently drop mail and the subscription will never activate. Sourced from RUNSON_ALERT_EMAIL in Doppler."
  type        = string

  validation {
    condition     = length(trimspace(var.email)) > 0
    error_message = "email is required. Set RUNSON_ALERT_EMAIL in Doppler (iac-conf-mgmt/prd) to a real inbox."
  }

  validation {
    # Trim before matching so accidental trailing/leading whitespace doesn't
    # let a noreply address sneak past the suffix check.
    condition     = !endswith(trimspace(var.email), "@users.noreply.github.com")
    error_message = "email must be a real inbox; GitHub noreply addresses cannot confirm SNS subscriptions."
  }
}

variable "alert_slack_webhook_url" {
  description = "Slack incoming-webhook URL for runs-on alerts (optional; empty disables Slack). Sourced from RUNSON_ALERT_SLACK_WEBHOOK_URL in Doppler. Both email and Slack can be enabled simultaneously."
  type        = string
  default     = ""
  sensitive   = true
}

variable "otel_exporter_endpoint" {
  description = "OpenTelemetry exporter endpoint (Cribl.Cloud OTLP URL)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "otel_exporter_headers" {
  description = "OpenTelemetry exporter headers (W3C Baggage format)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "monthly_budget_usd" {
  description = "Monthly AWS Budget alarm threshold in USD for the RunsOn cost-filter set in budget.tf. Default 20 covers the v3 baseline (control plane + EC2 spot + CloudWatch) plus the managed WAF when enable_waf=true. Drop to ~$10 if you set enable_waf=false."
  type        = number
  default     = 20.0
}

variable "app_size" {
  description = "RunsOn control-plane size (v3 flex submodule). One of: small, medium, high, xhigh. Replaces `app_cpu`/`app_memory`/`ec2_queue_size` from v2."
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "high", "xhigh"], var.app_size)
    error_message = "app_size must be one of: small, medium, high, xhigh."
  }
}

variable "app_budget_daily_usd" {
  description = "Per-day spend ceiling for the RunsOn fleet (v3 replacement for the v2 daily-minutes alarm). This is a runaway-cost safety cap, NOT an expected-spend target — the account-level monthly_budget_usd is the spend target. Set high enough that normal traffic never hits it; the failure mode is fleet halt on a bad day."
  type        = number
  default     = 5
}

variable "enable_waf" {
  description = "Attach the RunsOn-managed Web ACL to the v3 API Gateway ingress (one WAFv2 ACL + 3 rules — restricts /github/webhooks to GitHub's published IP ranges and tightens the public ingress posture). Default true. Adds AWS WAFv2 charges to the bill; flip to false if cost outweighs the hardening on this stack."
  type        = bool
  default     = true
}

variable "enable_admin_routes" {
  description = "Expose the public setup and admin routes on the v3 ingress. Keep true during initial bootstrap so the GitHub App can be registered. Flip to false once setup is complete to close the public admin surface."
  type        = bool
  default     = true
}

variable "enable_bedrock" {
  description = "Grant the RunsOn EC2 runner instance profile permission to invoke Amazon Bedrock models. Default false; opt in only when CI workflows need Bedrock model access (the model still has to be enabled in the AWS account separately)."
  type        = bool
  default     = false
}
