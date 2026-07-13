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
RunsOn v3 control plane (API Gateway + Lambda + ECS/Fargate, ~$3-5/month)
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

| Component                                          | Monthly     |
| -------------------------------------------------- | ----------- |
| Control plane (ECS/Fargate + Lambda + API Gateway) | ~$3-5       |
| EC2 spot                                           | ~$1-4       |
| CloudWatch (30d)                                   | ~$0.50      |
| WAFv2 (when `enable_waf = true`, default)          | ~$8         |
| **Total**                                          | **~$13-18** |

Budget alarm defaults to $20/month with alerts at 50%, 80%, 100%. Set
`enable_waf = false` to drop ~$8/month from the bill and `monthly_budget_usd`
back to ~$10 if you want the previous spend envelope.

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

## Onboarding a workflow

A workflow opts in to these runners by referencing the v3 RunsOn label
(`runs-on=${{ github.run_id }}/runner=...`) and installing the RunsOn GitHub
App on its repository. See [`docs/migration-guide.md`](docs/migration-guide.md)
for the full playbook: prerequisites, the runner label catalog, which workloads
suit self-hosted compute, rollout order, and how to verify a job landed on
RunsOn instead of GitHub-hosted compute.

## Installation

### Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled
- [direnv](https://direnv.net/)
- Access to the homelab Terrakube control plane
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

# Authenticate to Terrakube, load the tofu-runs-on TF_CLOUD_* coordinates,
# then start the remote run.
tofu init
tofu apply
```

### Post-setup hardening

Once the initial Terrakube apply completes and the GitHub App is registered through the
ingress URL, set `enable_admin_routes = false` (in `terraform.tfvars` or via
the matching OpenBao-backed workspace variable) and re-apply. This closes the public
`/admin` and `/setup` routes; the runners and webhook path keep working. The
managed WAF (`enable_waf`) is already attached by default.

### Optional: Bedrock model access from CI

Set `enable_bedrock = true` to grant the runner EC2 instance profile permission
to call Amazon Bedrock. The model itself still has to be enabled in the AWS
account separately before a workflow can invoke it.

## Development

```bash
direnv allow                  # Activate Nix shell
tofu init -backend=false      # Initialize for local validation
tofu validate                # Validate without remote credentials
```

## CI/CD

- **PR**: Automatic backend-free OpenTofu format and validation checks. Plans
  run privately in the `tofu-runs-on` Terrakube workspace; see
  [`docs/ci-plan-output-policy.md`](docs/ci-plan-output-policy.md).
- **Apply**: Terrakube remote run with OpenBao-managed workspace credentials
- **Releases**: Automated via Release Please

## Inputs & Outputs

Variable descriptions and defaults live in `variables.tf`; outputs in `outputs.tf`.

---

> Part of a [larger ecosystem of ~40 repos](https://docs.jacobpevans.com) — see how it all fits together.
