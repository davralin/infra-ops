output "public_ip" {
  value       = oci_core_instance.this.public_ip
  description = "Public IP of the OCI instance"
}

output "talosconfig" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
  description = "Talos client configuration"
}

output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "Kubernetes admin kubeconfig"
}
