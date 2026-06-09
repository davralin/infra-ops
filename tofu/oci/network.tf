resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["172.16.0.0/16"]
  display_name   = "${var.cluster_name}-vcn"
  freeform_tags  = local.common_tags
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  enabled        = true
  display_name   = "${var.cluster_name}-igw"
  freeform_tags  = local.common_tags
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.cluster_name}-rt"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.cluster_name}-sl"
  freeform_tags  = local.common_tags

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "17" # UDP
    source    = "0.0.0.0/0"
    stateless = false
    udp_options {
      min = 51820
      max = 51820
    }
  }

  ingress_security_rules {
    protocol  = "1" # ICMP
    source    = "0.0.0.0/0"
    stateless = false
  }

}

resource "oci_core_subnet" "this" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.this.id
  cidr_block        = "172.16.0.0/24"
  display_name      = "${var.cluster_name}-subnet"
  freeform_tags     = local.common_tags
  route_table_id    = oci_core_route_table.this.id
  security_list_ids = [oci_core_security_list.this.id]

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}
