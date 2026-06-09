resource "oci_core_image" "talos" {
  compartment_id = var.compartment_ocid
  display_name   = "Talos ${var.talos_version}"
  freeform_tags  = local.common_tags
  launch_mode    = "PARAVIRTUALIZED"

  image_source_details {
    source_type              = "objectStorageUri"
    source_uri               = var.talos_image_oci_bucket_url
    operating_system         = "Talos Linux"
    operating_system_version = var.talos_version
    source_image_type        = "QCOW2"
  }
}

resource "oci_core_shape_management" "talos" {
  compartment_id = var.compartment_ocid
  image_id       = oci_core_image.talos.id
  shape_name     = var.instance_shape
}
