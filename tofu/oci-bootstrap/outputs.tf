output "namespace" {
  value       = local.namespace
  description = "OCI Object Storage namespace (used for S3-compatible endpoint)"
}

output "state_bucket" {
  value       = oci_objectstorage_bucket.state.name
  description = "Bucket name for tofu state backend"
}

output "images_bucket" {
  value       = oci_objectstorage_bucket.images.name
  description = "Bucket name for Talos image upload"
}

output "backups_bucket" {
  value       = oci_objectstorage_bucket.backups.name
  description = "Bucket name for VolSync Restic backups"
}

output "s3_endpoint" {
  value       = "https://${local.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
  description = "S3-compatible endpoint for tofu backend config"
}
