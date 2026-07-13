# Plan-output policy

This repository is public. GitHub Actions logs, artifacts, and PR comments are
therefore not an approved location for AWS plan data, resource identifiers, or
resolved input values.

GitHub CI performs only backend-free static checks:

```bash
tofu fmt -check
tofu init -backend=false
tofu validate -no-color
```

Plans and applies run remotely in the homelab Terrakube `tofu-runs-on`
workspace. Terrakube owns state and locking, and receives runtime credentials
and sensitive inputs from OpenBao. Review the full plan in that authenticated
control plane; do not copy it into a public PR comment or workflow artifact.

If plan data is ever exported for diagnosis, treat it as sensitive, keep it in
homelab-controlled storage, and delete it after the review is complete.
