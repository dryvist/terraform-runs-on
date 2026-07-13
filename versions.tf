terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  cloud {
    hostname     = "terrakube-api.jacobpevans.com"
    organization = "dryvist"

    workspaces {
      name = "tofu-runs-on"
    }
  }
}
