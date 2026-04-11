# Terraform RunsOn - AI Agent Instructions

Self-hosted GitHub Actions runners on AWS EC2 spot instances via RunsOn.

## Technology Stack

- **Terraform/Terragrunt** - Infrastructure provisioning
- **GitHub Actions** - CI/CD (OIDC for AWS auth)
- **RunsOn** - Self-hosted runner orchestration
- **nix-devenv** - Dev shell via `shells/terraform` (includes aws-vault, awscli2, sops, tfsec, trivy)
- **aws-vault** - AWS credentials for S3 backend (profile: `tf-runs-on`)
- **Doppler** - Runtime secrets (RunsOn license key)

## Running Terraform Commands

**CRITICAL**: All Terragrunt commands require the complete toolchain wrapper.

### The Command (always this, always both)

```bash
aws-vault exec tf-runs-on -- doppler run -- terragrunt <COMMAND>
```

### Command Breakdown

1. **`aws-vault exec tf-runs-on`** - AWS credentials for S3 backend (profile: `tf-runs-on`)
2. **`doppler run --`** - Injects Doppler secrets as env vars (e.g., `RUNSON_LICENSE_KEY`)
3. **`terragrunt <COMMAND>`** - Runs Terraform

### Common Commands

```bash
aws-vault exec tf-runs-on -- doppler run -- terragrunt validate
aws-vault exec tf-runs-on -- doppler run -- terragrunt plan
aws-vault exec tf-runs-on -- doppler run -- terragrunt apply
```

### Claude Code Sessions

Start Claude inside aws-vault to get 1hr credential access without per-command popups:

```bash
cd ~/git/terraform-runs-on/main
aws-vault exec tf-runs-on -- claude
```

Then terragrunt commands only need Doppler (AWS credentials are inherited):

```bash
doppler run -- terragrunt plan
doppler run -- terragrunt apply
```

### Doppler Configuration

Doppler is configured at the `~/git/` scope (`iac-conf-mgmt/prd`), inherited by all repos.
No per-repo `doppler setup` needed. The `RUNSON_LICENSE_KEY` env var is mapped to
`license_key` via the `inputs` block in `terragrunt.hcl`.

## Dev Environment

Uses [nix-devenv](https://github.com/JacobPEvans/nix-devenv) terraform shell via direnv.
No local `flake.nix` — the remote shell provides all tooling with per-shell lock isolation.

```bash
direnv allow    # one-time per worktree, then automatic
```

## Architecture

- **VPC**: Dedicated VPC with 3 public subnets (us-east-2), no NAT Gateway
- **RunsOn**: Terraform module `runs-on/runs-on/aws` deploys App Runner + EC2 spot
- **OIDC**: GitHub Actions authenticates via OIDC (no stored AWS credentials in CI)
- **State**: S3 + DynamoDB via Terragrunt
- **Budget**: AWS Budget alarm at $10/month
- **Observability**: OTEL to Cribl.Cloud Free tier

## Secrets

| Secret | Source | Used By |
| ------ | ------ | ------- |
| `RUNSON_LICENSE_KEY` | Doppler (`iac-conf-mgmt/prd`) | Local: `doppler run`; CI: `ci-gate.yml` plan + `deploy.yml` apply |
| `TERRAFORM_RUNS_ON_OIDC_ROLE_ARN` | Doppler (`iac-conf-mgmt/prd`) | CI: `ci-gate.yml` plan + `deploy.yml` apply OIDC auth |
| `GH_ACTION_DOPPLER_IAC_CONF_MGMT` | GitHub repo secret (secrets-sync Tier 2) | `ci-gate.yml` + `deploy.yml` Doppler fetch step |
| AWS credentials | aws-vault profile `tf-runs-on` | Local terragrunt S3 backend auth |

Consumer repos using the deployed runner only need the RunsOn GitHub App
installed — they never need a license secret.

## Cost Target

~$5-8/month: App Runner (~$3) + EC2 spot (~$1-4) + CloudWatch ($0.50).
Budget alarm alerts at 50%, 80%, 100% of $10/month.

## Going public checklist

When flipping this repo from private to public, follow every step. Skipping
any of these will leak AWS account IDs, resource ARNs, or structural hints.

1. **Run a sensitive-data sweep on every PR comment (all states, full
   history).** Any `#### Terraform Plan` comment posted by
   `github-actions[bot]` contains the raw plan output with account IDs and
   ARNs. Delete them before flipping public. Uses REST `--paginate` so every
   PR and every comment is covered regardless of repo volume. The same
   `env -u GITHUB_TOKEN` is used for the listing and the delete so the
   same token (with `issues:write`) handles both calls:

   ```bash
   REPO=JacobPEvans/terraform-runs-on
   env -u GITHUB_TOKEN gh api --paginate \
     "repos/${REPO}/pulls?state=all&per_page=100" \
     --jq '.[].number' \
   | while read PR; do
       env -u GITHUB_TOKEN gh api --paginate \
         "repos/${REPO}/issues/${PR}/comments?per_page=100" \
         --jq '.[] | select(.body | startswith("#### Terraform Plan"))
                   | .id' \
       | while read CID; do
           env -u GITHUB_TOKEN gh api -X DELETE \
             "repos/${REPO}/issues/comments/${CID}"
         done
     done
   ```

2. **Delete workflow run logs for every historical Deploy or CI Gate run
   before the log-masking PR merged.** The current workflow uses
   `mask-aws-account-id: true` on `aws-actions/configure-aws-credentials`,
   fetches VPC/SG/Secrets Manager ARNs via the AWS CLI and feeds them to
   `core.setSecret` in an `actions/github-script` step, redirects
   `terragrunt plan` stdout to `/dev/null`, and posts a structured
   summary (derived from `tofu show -json tfplan` via
   `actions/github-script`) to the PR instead of the raw plan text.
   Older runs predating these mitigations need their logs deleted.
   Uses `--paginate` to walk beyond the default 100-run page and the
   same `env -u GITHUB_TOKEN` on both list and delete so auth is
   consistent:

   ```bash
   REPO=JacobPEvans/terraform-runs-on
   env -u GITHUB_TOKEN gh api --paginate \
     "repos/${REPO}/actions/runs?per_page=100" \
     --jq '.workflow_runs[]
           | select(.name == "Deploy" or .name == "CI Gate")
           | .id' \
   | while read RUN; do
       env -u GITHUB_TOKEN gh api -X DELETE \
         "repos/${REPO}/actions/runs/${RUN}/logs" || true
     done
   ```

3. **Confirm the latest CI Gate run on the PR you're about to merge**
   posts a `## Terraform Plan` comment whose body contains only a
   `| Action | Type | Address |` table — no attribute values, no ARNs,
   no account ID, no VPC/SG/Secrets Manager identifiers. Full
   attribute-level detail must only be available via the
   `tfplan-<run_id>` workflow artifact (which is access-gated to repo
   members). And confirm the raw workflow log of the Terragrunt Plan
   step shows no text diff — only the binary plan file was written.

4. **Run pre-commit gitleaks locally** before pushing the flip:

   ```bash
   pre-commit run gitleaks --all-files
   ```

5. **Verify no unstaged or stashed changes contain real account IDs or
   ARNs.** Check `git stash list`, `git status`, and any uncommitted
   `.terragrunt-cache/` artifacts (the cache is gitignored but not scrubbed).

Flip the visibility only after all five steps pass. See the `eager-launching-badger`
plan (Phase 5) for the full audit/remediation history that established this
checklist.

## Worktree Structure

```text
~/git/terraform-runs-on/
  .git/     # Bare repo
  main/     # Main branch worktree
  feat/     # Feature worktrees
```
