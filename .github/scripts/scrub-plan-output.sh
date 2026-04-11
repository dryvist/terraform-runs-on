#!/usr/bin/env bash
# Redact sensitive structural identifiers from terragrunt plan output before
# posting it to a GitHub PR comment. The mask-aws-account-id feature of
# aws-actions/configure-aws-credentials only masks values in the log display
# stream — it does not rewrite file contents. Anything read from disk and
# passed to the GitHub API (like actions/github-script reading plan_output.txt
# and calling createComment) bypasses the mask entirely. This script closes
# that gap by rewriting the file before it is posted.
#
# Requires the following environment variable:
#   AWS_ACCOUNT_ID  - the live 12-digit account ID, from the aws-account-id
#                     output of aws-actions/configure-aws-credentials
#
# Optional first argument: path to the plan output file. Defaults to
# plan_output.txt in the current directory.

set -euo pipefail

: "${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID must be set}"

PLAN_FILE="${1:-plan_output.txt}"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "scrub-plan-output: file not found: $PLAN_FILE" >&2
  exit 1
fi

# Redact the AWS account ID wherever it appears (ARNs, SQS URLs, bucket names,
# assumed-role sessions, etc.).
sed -i "s/${AWS_ACCOUNT_ID}/REDACTED/g" "$PLAN_FILE"

# Redact the full Secrets Manager secret path. AWS embeds a stable config
# hash AND appends a 6-character random suffix — both together uniquely
# identify the secret, so redacting just the suffix still leaks the hash.
# Redact everything after ":secret:" up to the next whitespace or quote.
sed -i -E 's|:secret:[^ "]+|:secret:REDACTED|g' "$PLAN_FILE"

# Redact VPC IDs and Security Group IDs — they reveal topology and enable
# targeted resource enumeration against the account.
sed -i -E 's/vpc-[0-9a-f]{8,17}/vpc-REDACTED/g' "$PLAN_FILE"
sed -i -E 's/sg-[0-9a-f]{8,17}/sg-REDACTED/g' "$PLAN_FILE"

echo "scrub-plan-output: $PLAN_FILE scrubbed"
