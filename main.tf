module "runs_on" {
  source  = "runs-on/runs-on/aws"
  version = "~> 2.12"

  # Required.
  # license_key is sourced from RUNSON_LICENSE_KEY at runtime:
  #   - Local: `doppler run` injects it from iac-conf-mgmt/prd
  #   - CI:    dopplerhq/secrets-fetch-action injects it in ci-gate.yml
  #            and deploy.yml using the GH_ACTION_DOPPLER_IAC_CONF_MGMT token
  # terragrunt.hcl reads it via get_env("RUNSON_LICENSE_KEY", "") and maps
  # it to this variable.
  github_organization = var.github_organization
  license_key         = var.license_key
  email               = var.email
  vpc_id              = aws_vpc.runs_on.id
  public_subnet_ids   = aws_subnet.public[*].id

  # Non-default overrides
  logger_level        = "debug"
  log_retention_days  = 30
  default_admins      = "JacobPEvans"
  cost_allocation_tag = "runs-on"
  tags                = local.common_tags

  # OTEL — Cribl.Cloud Free endpoint
  otel_exporter_endpoint = var.otel_exporter_endpoint
  otel_exporter_headers  = var.otel_exporter_headers
}
