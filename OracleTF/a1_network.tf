# Creates a private subnet for the A1 instance that should not receive a public IP
resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = "always-free-private-subnet"
  security_list_ids          = [oci_core_security_list.private_instance_security_list.id]
  prohibit_public_ip_on_vnic = true
  dhcp_options_id            = oci_core_vcn.vcn.default_dhcp_options_id
}

# Creates a Security List for the A1 instance reachable only from inside the VCN
resource "oci_core_security_list" "private_instance_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "always-free-private-sl"

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = oci_core_vcn.vcn.cidr_block
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "1" # ICMP
    source    = oci_core_vcn.vcn.cidr_block
    stateless = false
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}
