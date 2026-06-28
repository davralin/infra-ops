locals {
  # renovate: datasource=helm registryUrl=https://helm.cilium.io depName=cilium
  cilium_version = "1.19.4"
}

resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  create_namespace = false
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = local.cilium_version
  wait             = true
  timeout          = 300

  values = [yamlencode({
    ipv6 = {
      enabled = true
    }
    ipam = {
      mode = "kubernetes"
    }
    kubeProxyReplacement = true
    securityContext = {
      capabilities = {
        ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    cgroup = {
      autoMount = {
        enabled = false
      }
      hostRoot = "/sys/fs/cgroup"
    }
    k8sServiceHost = "localhost"
    k8sServicePort = "7445"
    operator = {
      replicas = 1
    }
    gatewayAPI = {
      enabled = true
    }
    updateStrategy = {
      type = "RollingUpdate"
      rollingUpdate = {
        maxSurge = 0
        maxUnavailable = 1
      }
    }
  })]
}
