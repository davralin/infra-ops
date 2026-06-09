locals {
  compartment_id = var.tenancy_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = local.compartment_id
}

resource "oci_objectstorage_bucket" "state" {
  compartment_id = local.compartment_id
  namespace      = local.namespace
  name           = "infra-ops-state"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"

  versioning = "Enabled"
}

resource "oci_objectstorage_bucket" "images" {
  compartment_id = local.compartment_id
  namespace      = local.namespace
  name           = "infra-ops-images"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
}

resource "oci_objectstorage_bucket" "backups" {
  compartment_id = local.compartment_id
  namespace      = local.namespace
  name           = "infra-ops-backups"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
}
