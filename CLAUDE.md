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

1. **Run a sensitive-data sweep on every open PR comment.** Any `#### Terraform
   Plan` comment posted by `github-actions[bot]` contains the raw plan output
   with account IDs and ARNs. Delete them before flipping public:

   ```bash
   REPO=JacobPEvans/terraform-runs-on
   for PR in $(gh pr list --repo "$REPO" --state all --limit 50 \
                 --json number --jq '.[].number'); do
     gh api graphql -f query="query { repository(owner:\"JacobPEvans\",
         name:\"terraform-runs-on\") { pullRequest(number:${PR}) {
         comments(first:50) { nodes { databaseId body } } } } }" \
       --jq '.data.repository.pullRequest.comments.nodes[]
             | select(.body | startswith("#### Terraform Plan"))
             | .databaseId' \
       | while read CID; do
           env -u GITHUB_TOKEN gh api -X DELETE \
             "repos/${REPO}/issues/comments/${CID}"
         done
   done
   ```

2. **Delete workflow run logs for any run in the last 90 days that ran
   `Terragrunt Plan` or `Terragrunt Apply` before the log-masking PR merged.**
   The `mask-aws-account-id: true` + scrub-plan-output combo handles future
   runs, but older runs were captured before those mitigations landed:

   ```bash
   REPO=JacobPEvans/terraform-runs-on
   gh run list --repo "$REPO" --limit 100 \
     --json databaseId,workflowName \
     --jq '.[] | select(.workflowName == "Deploy"
                     or .workflowName == "CI Gate")
               | .databaseId' \
     | while read RUN; do
         env -u GITHUB_TOKEN gh api -X DELETE \
           "repos/${REPO}/actions/runs/${RUN}/logs" || true
       done
   ```

3. **Confirm the most recent CI Gate run on the PR you're about to merge
   shows `***` where the account ID would appear in the raw log**, and its
   posted plan comment contains `REDACTED` (not digits) for account ID,
   Secrets Manager ARN suffixes, VPC IDs, and security group IDs.

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
