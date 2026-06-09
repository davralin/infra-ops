resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.wireguard_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs     = false
  examples = false

  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
        proxy = {
          disabled = true
        }
        scheduler = {
          extraArgs = {
            bind-address = "0.0.0.0"
          }
        }
        controllerManager = {
          extraArgs = {
            bind-address = "0.0.0.0"
          }
        }
        etcd = {
          extraArgs = {
            listen-metrics-urls = "http://0.0.0.0:2381"
          }
        }
        apiServer = {
          admissionControl = [
            {
              name = "PodSecurity"
              configuration = {
                defaults = {
                  enforce = "restricted"
                }
              }
            }
          ]
          certSANs = [var.wireguard_ip]
        }
        discovery = {
          enabled = false
        }
        network = {
          cni            = { name = "none" }
          podSubnets     = ["172.20.0.0/16"]
          serviceSubnets = ["172.21.0.0/16"]
        }
      }
    }),

    yamlencode({
      machine = {
        certSANs = [var.wireguard_ip]
        install = {
          disk  = "/dev/sda"
          image = "factory.talos.dev/installer/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba:${var.talos_version}"
          extraKernelArgs = [
            "console=ttyAMA0",
            "talos.platform=oracle",
          ]
          wipe = false
        }
        time = {
          servers = ["169.254.169.254"]
        }
        systemDiskEncryption = {
          state = {
            provider = "luks2"
            keys = [{
              nodeID = {}
              slot   = 0
            }]
          }
          ephemeral = {
            provider = "luks2"
            keys = [{
              nodeID = {}
              slot   = 0
            }]
            options = [
              "no_read_workqueue",
              "no_write_workqueue",
            ]
          }
        }
        features = {
          kubernetesTalosAPIAccess = {
            enabled = true
            allowedRoles = [
              "os:admin",
              "os:etcd:backup",
            ]
            allowedKubernetesNamespaces = ["talos-system"]
          }
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
        network = {
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
            }
          ]
        }
      }
    }),

    <<-EOT
apiVersion: v1alpha1
kind: WireguardConfig
name: wg0
privateKey: ${var.wireguard_private_key}
listenPort: 51820
mtu: 1420
addresses:
  - address: ${var.wireguard_ip}/24
routes:
  - destination: 10.0.1.0/24
peers:
  - publicKey: Jx1HCHCbkpP6o1ZJy2mP3BknmE/OB8aoBBb5NRT29WE=
    persistentKeepaliveInterval: 25s
    allowedIPs:
      - 10.0.2.0/24
      - 10.0.1.0/24
EOT
  ]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = var.wireguard_ip
  endpoint                    = var.wireguard_ip
  apply_mode                  = "staged_if_needing_reboot"

  depends_on = [talos_machine_bootstrap.this]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.wireguard_ip
  endpoint             = var.wireguard_ip

  depends_on = [oci_core_instance.this]

  lifecycle {
    ignore_changes = all
  }
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.wireguard_ip
  endpoint             = var.wireguard_ip

  depends_on = [talos_machine_bootstrap.this]
}

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = [var.wireguard_ip]
  endpoints            = [var.wireguard_ip]

  timeouts = {
    read = "5m"
  }

  depends_on = [talos_machine_configuration_apply.this]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.wireguard_ip]
  nodes                = [var.wireguard_ip]
}
