provider "vault" {
  skip_child_token = true
}

ephemeral "vault_aws_access_credentials" "this" {
  mount  = "aws"
  role   = "tofu-runs-on"
  type   = "sts"
  region = "us-east-2"
  ttl    = "1h"
}

provider "aws" {
  region     = "us-east-2"
  access_key = ephemeral.vault_aws_access_credentials.this.access_key
  secret_key = ephemeral.vault_aws_access_credentials.this.secret_key
  token      = ephemeral.vault_aws_access_credentials.this.security_token

  default_tags {
    tags = local.common_tags
  }
}
