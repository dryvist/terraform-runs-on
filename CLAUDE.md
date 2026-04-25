# terraform-runs-on

Self-hosted GitHub Actions runners on AWS EC2 spot via [RunsOn](https://runs-on.com).

Architecture and usage: see `README.md`. Repo rules auto-load from
`.claude/rules/` — the terragrunt-command wrapper rule is the most
important one for any change in this repo.
