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
  description = "Email for cost and alert reports"
  type        = string
  default     = "20714140+JacobPEvans@users.noreply.github.com"
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
  description = "Monthly budget limit in USD"
  type        = number
  default     = 10.0
}

variable "app_size" {
  description = "RunsOn control-plane size (v3 flex submodule). Replaces `app_cpu`/`app_memory`/`ec2_queue_size` from v2."
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.app_size)
    error_message = "app_size must be one of: small, medium, large, xlarge."
  }
}

variable "app_budget_daily_usd" {
  description = "Per-day spend ceiling for the RunsOn fleet (v3 replacement for the v2 daily-minutes alarm). This is a runaway-cost safety cap, NOT an expected-spend target — the account-level monthly_budget_usd is the spend target. Set high enough that normal traffic never hits it; the failure mode is fleet halt on a bad day."
  type        = number
  default     = 5
}
