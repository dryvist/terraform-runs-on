# terraform-runs-on

Self-hosted GitHub Actions runners on AWS EC2 spot instances via [RunsOn](https://runs-on.com).

## What This Does

Deploys RunsOn infrastructure to AWS, providing self-hosted GitHub Actions runners that are:

- **10x cheaper** than GitHub-hosted runners (EC2 spot instances)
- **2x faster** (dedicated compute, no queue wait)
- **Auto-scaling** (runners spin up on demand, terminate when done)

## Architecture

```text
GitHub Actions Workflow
        |
        v
RunsOn App Runner (orchestrator, ~$3/month)
        |
        v
EC2 Spot Instances (runners, ~$0.03/hr)
  - 3 AZs in us-east-2
  - Spot circuit breaker (auto-fallback to on-demand)
  - Cost allocation tags per workflow/job/repo
        |
        v
Cribl.Cloud Free (observability, $0/month)
  - OTLP telemetry
  - Forward to Splunk/S3
```

## Cost

| Component | Monthly |
| --------- | ------- |
| App Runner | ~$3 |
| EC2 spot | ~$1-4 |
| CloudWatch (30d) | ~$0.50 |
| **Total** | **~$5-8** |

Budget alarm at $10/month with alerts at 50%, 80%, 100%.

## Usage

After deployment, use RunsOn runners in any workflow:

```yaml
jobs:
  build:
    runs-on: "runs-on=${{ github.run_id }}/runner=2cpu-linux-x64/family=c7+m7"
    steps:
      - uses: actions/checkout@v6
      - run: echo "Running on RunsOn!"
```

The `${{ github.run_id }}` segment is required so RunsOn can correlate the
`workflow_job` event back to the originating run. See the [RunsOn job labels
documentation](https://runs-on.com/configuration/job-labels/) for runner sizes
and other options.

## Installation

### Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled
- [direnv](https://direnv.net/)
- [aws-vault](https://github.com/99designs/aws-vault) with a `tf-runs-on` profile
- A [RunsOn](https://runs-on.com) license key

### Setup

```bash
# Clone with bare repo + worktree convention
cd ~/git
git clone --bare https://github.com/JacobPEvans/terraform-runs-on.git terraform-runs-on/.git
cd terraform-runs-on
git worktree add main main

# Activate dev shell
cd main
direnv allow

# Bootstrap infrastructure
aws-vault exec tf-runs-on -- doppler run -- terragrunt init
aws-vault exec tf-runs-on -- doppler run -- terragrunt apply
```

## Development

```bash
direnv allow                                                        # Activate Nix shell
aws-vault exec tf-runs-on -- doppler run -- terragrunt plan         # Preview changes
aws-vault exec tf-runs-on -- doppler run -- terragrunt apply        # Apply changes
```

## CI/CD

- **PR**: Automatic `terraform validate` + `terragrunt plan` (posted as PR comment)
- **Merge to main**: Automatic `terragrunt apply` via OIDC (requires `production` environment approval)
- **Releases**: Automated via Release Please

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.45.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_runs_on"></a> [runs\_on](#module\_runs\_on) | runs-on/runs-on/aws//modules/flex | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.runs_on](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.runs_on](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.runs_on](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.github_actions_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_budget_daily_usd"></a> [app\_budget\_daily\_usd](#input\_app\_budget\_daily\_usd) | Daily spend ceiling for the RunsOn fleet in USD (v3 replacement for the daily-minutes alarm). 5 USD/day pairs with the existing 10 USD/month account budget. | `number` | `5` | no |
| <a name="input_app_size"></a> [app\_size](#input\_app\_size) | RunsOn control-plane size (v3 flex submodule). Replaces app\_cpu/app\_memory/ec2\_queue\_size from v2. Valid: small, medium, large, xlarge. | `string` | `"small"` | no |
| <a name="input_email"></a> [email](#input\_email) | Email for cost and alert reports | `string` | `"20714140+JacobPEvans@users.noreply.github.com"` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub organization or username | `string` | `"JacobPEvans"` | no |
| <a name="input_license_key"></a> [license\_key](#input\_license\_key) | RunsOn license key | `string` | n/a | yes |
| <a name="input_monthly_budget_usd"></a> [monthly\_budget\_usd](#input\_monthly\_budget\_usd) | Monthly budget limit in USD | `number` | `10` | no |
| <a name="input_otel_exporter_endpoint"></a> [otel\_exporter\_endpoint](#input\_otel\_exporter\_endpoint) | OpenTelemetry exporter endpoint (Cribl.Cloud OTLP URL) | `string` | `""` | no |
| <a name="input_otel_exporter_headers"></a> [otel\_exporter\_headers](#input\_otel\_exporter\_headers) | OpenTelemetry exporter headers (W3C Baggage format) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | Name of the AWS Budget |
| <a name="output_github_actions_role_arn"></a> [github\_actions\_role\_arn](#output\_github\_actions\_role\_arn) | IAM role ARN for GitHub Actions OIDC authentication |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
