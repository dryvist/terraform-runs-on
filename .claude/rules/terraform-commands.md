---
description: OpenTofu and Terrakube command execution rules for this repository
globs:
  - "*.tf"
  - "*.hcl"
---

# OpenTofu command rules

State, locking, plans, and applies belong to the homelab Terrakube
`tofu-runs-on` workspace. The workspace receives AWS and RunsOn credentials
from OpenBao; do not place them in this repository, GitHub Actions, or a local
tfvars file.

Local checks are intentionally backend-free:

```bash
tofu fmt -check
tofu init -backend=false
tofu validate
```

Use `tofu plan` and `tofu apply` only after authenticating to Terrakube and
loading the runtime `TF_CLOUD_*` coordinates. Never target an apply or attempt
to recreate the retired AWS state backend.
