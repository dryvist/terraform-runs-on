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
  description = "RunsOn control-plane size (v3 flex submodule). Replaces app_cpu/app_memory/ec2_queue_size from v2. Valid: small, medium, large, xlarge."
  type        = string
  default     = "small"
}

variable "app_budget_daily_usd" {
  description = "Daily spend ceiling for the RunsOn fleet in USD (v3 replacement for the daily-minutes alarm). 5 USD/day pairs with the existing 10 USD/month account budget."
  type        = number
  default     = 5
}
