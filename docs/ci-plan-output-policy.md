# CI plan-output policy

This repo is public. The Actions UI, workflow logs, artifacts, and PR
comments are world-readable. Terraform plan output contains AWS infra
topology — API Gateway IDs, S3 bucket names, Lambda source hashes,
security-group rule contents, and resolved attribute values — that
should not become a permanent public record of the account's
internal layout.

## What ships in PR comments

The `Terraform Plan` job in `.github/workflows/ci-gate.yml` posts a
single sticky comment per PR using
[`dineshba/tf-summarize`](https://github.com/dineshba/tf-summarize)
against the JSON plan representation. The comment contains:

- The count of resources being added, changed, replaced, or destroyed.
- The terraform *addresses* of those resources (e.g.
  `module.runs_on.aws_apigatewayv2_api.this[0]`). These are the
  block labels in the committed `.tf` files; they are public by
  construction.

That's it.

## What does not ship in PR comments

`tf-summarize` is a structural projector: it reads the documented
[terraform JSON plan representation](https://developer.hashicorp.com/terraform/internals/json-format#plan-representation)
and renders only the fields above. The following are never rendered,
not because a regex filters them out, but because the tool does not
project them:

- `resource_changes[*].change.before` — pre-change attribute values.
- `resource_changes[*].change.after` — post-change attribute values.
- `resource_changes[*].change.after_unknown` — computed attributes.
- `prior_state` / `planned_values` — full resource bodies.
- `configuration.root_module` — variable values, locals, raw
  expressions.

This is the structural safety property: the leak class that caused
the PR #64 incident (API Gateway REST API ID, S3 cache bucket name
with embedded timestamp, Lambda source hashes, per-method API Gateway
integration IDs) cannot recur through the comment surface, because
the resolved attribute values that contain those identifiers are
never emitted at all.

## What does not ship in workflow logs

The plan step runs:

```bash
terragrunt plan -out=plan.tfplan -no-color > /dev/null
```

The plan binary is consumed by the next step, which pipes
`terragrunt show -json plan.tfplan` into `tf-summarize -md` and
writes the result to `summary.md`. Neither command echoes the
resolved plan to the workflow log; the only artifact is the
structural Markdown, which the next step posts to the PR comment.

`TERRAGRUNT_LOG_DISABLE: "true"` further suppresses terragrunt's own
informational lines (state-bucket and lock-table names) on every
step in the job.

## What you do when you need the full plan

Re-run the plan locally:

```bash
aws-vault exec tf-runs-on -- doppler run -- terragrunt plan
```

The output stays on your machine. This matches
[`.claude/rules/terraform-commands.md`](../.claude/rules/terraform-commands.md)
— plan is a developer-local activity; CI exists to gate fmt,
validate, and the structural review signal.

## Why not "just mask the bad parts"

The previous defense was a `TFCMT_MASKS` regex denylist matching
12-digit account IDs, ARNs, 64-char hex digests, and prefixed EC2/VPC
short IDs. It did not catch the identifiers that leaked through
PR #64 because their shapes were not in the regex set:

- API Gateway REST API IDs (10-char alphanumeric, no prefix)
- S3 bucket names (custom strings with timestamps)
- Lambda source hashes shorter than 64 chars
- Integration IDs (same shape as REST API IDs)

Denylists scale with the union of every identifier shape AWS will
ever emit. They are structurally unable to keep pace, and a missing
pattern is silent — the leak ships and no one notices until someone
reads the comment thread. Structural projection makes the safety
property hold by construction.

## What about "we'd like to see the full plan in CI" later

GitHub-hosted Actions logs and artifacts on a public repo are
world-readable. No masker can make raw `terragrunt plan` output
safe to print there. If we want full plan visibility for trusted
reviewers in the future, the practical options are:

1. Upload the plan JSON to a private S3 bucket the operator owns,
   gated by a bucket policy that allows only their AWS identity.
   The PR comment includes a short-lived presigned URL that only
   the operator can use.
2. DM the plan to a private Slack channel via webhook.
3. Run the full plan on a separate private mirror repo whose Actions
   logs are collaborator-only, triggered via `workflow_run`.

Deferred — pick up if/when full-plan visibility for trusted
reviewers becomes a priority.

## Audit recipe

If you suspect a regression, re-run this audit against any PR
comment posted by `tf-plan-summary`:

```bash
# Expected: zero matches across all patterns.
gh pr view <PR> --comments --json comments | jq -r '
  .comments[] | select(.body | startswith("<!-- Sticky Pull Request Comment")) | .body
' | grep -E \
  -e 'p[0-9a-z]{9}' \
  -e 'runs-on-cache-[0-9]{17,}' \
  -e 'arn:aws:' \
  -e '\b[0-9]{12}\b' \
  -e '\b[a-f0-9]{64}\b' \
  -e '\b(vpc|subnet|sg|lt|i|ami|eni|tgw)-[a-f0-9]{8,17}\b'
```

Patterns, in order: API Gateway 10-char IDs, bucket names with
embedded timestamps, AWS ARNs, 12-digit account IDs, 64-char hex
digests, EC2/VPC short IDs.

A match is a real regression, not a false positive. `tf-summarize`
should never emit these shapes; if any appear, file an issue against
this repo and `dineshba/tf-summarize` upstream.
