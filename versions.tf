terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state, locking, and execution are provided by the homelab Terrakube
  # control plane. Runtime TF_CLOUD_* coordinates select the tofu-runs-on
  # workspace without publishing internal endpoints in this repository.
  cloud {}
}
