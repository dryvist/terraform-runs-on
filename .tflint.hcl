# Synced from dryvist/.github precommit/configs/tflint.hcl — keep in
# lockstep with that canonical. Renovate sync of precommit/configs/ is
# queued; refresh manually for now.

config {
  format           = "compact"
  call_module_type = "local"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}
