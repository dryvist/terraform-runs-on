#!/usr/bin/env bash
# Install Terragrunt into a user-writable directory and verify its checksum.
#
# Requires the following environment variable:
#   TG_VERSION  - Terragrunt release tag (e.g. "v1.0.0")
#
# Installs to "$HOME/.local/bin" and appends that directory to "$GITHUB_PATH"
# so subsequent workflow steps find "terragrunt" in PATH. This path is
# writable by the runner user on both GitHub-hosted and self-hosted runners,
# which is why we avoid /usr/local/bin.
#
# The binary is verified against the official SHA256SUMS asset from the
# gruntwork-io/terragrunt release before being installed.

set -euo pipefail

: "${TG_VERSION:?TG_VERSION must be set (e.g. v1.0.0)}"

BIN_DIR="$HOME/.local/bin"
TG_BIN="terragrunt_linux_amd64"
BASE="https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}"

mkdir -p "$BIN_DIR"
echo "$BIN_DIR" >>"$GITHUB_PATH"

curl -sSfLo "/tmp/${TG_BIN}" "${BASE}/${TG_BIN}"
curl -sSfLo /tmp/SHA256SUMS "${BASE}/SHA256SUMS"

# Extract just the line for our binary and verify from /tmp so the relative
# path in SHA256SUMS matches the downloaded file.
grep " ${TG_BIN}$" /tmp/SHA256SUMS | (cd /tmp && sha256sum -c -)

install -m 0755 "/tmp/${TG_BIN}" "$BIN_DIR/terragrunt"
"$BIN_DIR/terragrunt" --version
