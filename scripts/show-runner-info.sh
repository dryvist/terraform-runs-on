#!/usr/bin/env bash
set -euo pipefail

echo "=== uname ==="
uname -a
echo
echo "=== arch ==="
uname -m
echo
echo "=== cpus ==="
nproc
echo
echo "=== memory ==="
free -h
echo
echo "=== disk ==="
df -h /
echo
echo "=== env (filtered) ==="
env | grep -E '^(RUNNER_|GITHUB_|CI|HOSTNAME)=' | sort || true
