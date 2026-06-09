variable "tenancy_ocid" {
  type      = string
  sensitive = true
}

variable "user_ocid" {
  type      = string
  sensitive = true
}

variable "fingerprint" {
  type      = string
  sensitive = true
}

variable "private_key_path" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "eu-stockholm-1"
}

variable "compartment_ocid" {
  type      = string
  sensitive = true
}

variable "availability_domain" {
  type    = string
  default = "WWat:EU-STOCKHOLM-1-AD-1"
}

variable "wireguard_ip" {
  type    = string
  default = "10.0.2.6"
}

variable "cluster_name" {
  type    = string
  default = "oci"
}

variable "talos_version" {
  type    = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "v1.13.4"
}

variable "kubernetes_version" {
  type    = string
  # renovate: datasource=docker depName=ghcr.io/siderolabs/kubelet
  default = "v1.36.1"
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  type    = number
  default = 4
}

variable "instance_memory_in_gbs" {
  type    = number
  default = 24
}

variable "boot_volume_size_in_gbs" {
  type    = number
  default = 200
}

variable "talos_image_oci_bucket_url" {
  type        = string
  description = "Dedicated endpoint URL of the Talos OCI image in Object Storage"
}

variable "wireguard_private_key" {
  type        = string
  sensitive   = true
  description = "WireGuard private key for the OCI node"
}
