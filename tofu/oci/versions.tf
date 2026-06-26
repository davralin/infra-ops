terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11"
    }
  }
  required_version = ">= 1.8"

  backend "s3" {
    bucket = "infra-ops-state"
    key    = "oci/terraform.tfstate"
    region = "eu-stockholm-1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}

