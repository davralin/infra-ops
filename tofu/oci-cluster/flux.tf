locals {
  # renovate: datasource=docker depName=ghcr.io/controlplaneio-fluxcd/charts/flux-operator
  flux_operator_version = "0.53.0"
}

resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  namespace        = "flux-system"
  create_namespace = true
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  version          = local.flux_operator_version
  wait             = true
  timeout          = 300

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "flux_instance" {
  yaml_body = file("${path.module}/../../kubernetes/clusters/oci/flux-instance.yaml")

  depends_on = [helm_release.flux_operator]
}
