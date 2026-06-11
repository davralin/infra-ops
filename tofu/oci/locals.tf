locals {
  common_tags = {
    cluster = var.cluster_name
  }

  # Talos image schematic — bakes talos.platform=oracle + net.ifnames=0 into UKI
  # renovate: datasource=github-tags depName=siderolabs/talos
  talos_schematic = "ffbce43d91d29663a98eecd1b5085b64cb8c1eb1612db3bcaa4c2d97b8b4323d"

  # Parse OCI Object Storage URL: .../n/<namespace>/b/<bucket>/o/<object>
  image_url_parts     = split("/", var.talos_image_oci_bucket_url)
  image_oci_namespace = local.image_url_parts[index(local.image_url_parts, "n") + 1]
  image_oci_bucket    = local.image_url_parts[index(local.image_url_parts, "b") + 1]
  image_oci_object    = local.image_url_parts[index(local.image_url_parts, "o") + 1]
}
