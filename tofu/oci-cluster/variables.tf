variable "kube_host" {
  type        = string
  description = "Kubernetes API server URL"
  default     = "https://10.0.2.6:6443"
}

variable "kube_client_certificate" {
  type        = string
  sensitive   = true
  description = "Base64-encoded client certificate from kubeconfig"
}

variable "kube_client_key" {
  type        = string
  sensitive   = true
  description = "Base64-encoded client key from kubeconfig"
}

variable "kube_cluster_ca_certificate" {
  type        = string
  sensitive   = true
  description = "Base64-encoded cluster CA certificate from kubeconfig"
}
