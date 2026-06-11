# Build and upload the Talos OCI image to Object Storage before importing it.
# The provisioner runs whenever version, schematic, or target object changes.
resource "terraform_data" "talos_image_object" {
  triggers_replace = {
    version   = var.talos_boot_image_version
    schematic = local.talos_schematic
    object    = local.image_oci_object
  }

  provisioner "local-exec" {
    command = <<-EOT
      ${path.module}/scripts/build-talos-oci-image.sh \
        --version   ${var.talos_boot_image_version} \
        --schematic ${local.talos_schematic} \
        --namespace ${local.image_oci_namespace} \
        --bucket    ${local.image_oci_bucket} \
        --object    ${local.image_oci_object}
    EOT
  }
}

resource "oci_core_image" "talos" {
  compartment_id = var.compartment_ocid
  display_name   = "Talos ${var.talos_boot_image_version}"
  freeform_tags  = local.common_tags
  launch_mode    = "PARAVIRTUALIZED"

  image_source_details {
    source_type              = "objectStorageUri"
    source_uri               = var.talos_image_oci_bucket_url
    operating_system         = "Talos Linux"
    operating_system_version = var.talos_boot_image_version
    source_image_type        = "QCOW2"
  }

  depends_on = [terraform_data.talos_image_object]
}

resource "oci_core_shape_management" "talos" {
  compartment_id = var.compartment_ocid
  image_id       = oci_core_image.talos.id
  shape_name     = var.instance_shape
}
