# Creates a Virtual Cloud Network (VCN)
resource "oci_core_vcn" "vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "always-free-vcn"
}

# Creates a public subnet for the VM
resource "oci_core_subnet" "public_subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "always-free-public-subnet"
  security_list_ids = [oci_core_security_list.web_and_ssh_security_list.id]
  route_table_id    = oci_core_route_table.public_route_table.id
  dhcp_options_id   = oci_core_vcn.vcn.default_dhcp_options_id
}

# Creates an Internet Gateway to allow internet access
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "always-free-ig"
}

# Creates a Route Table for the public subnet
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "always-free-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Creates a Security List to allow SSH, HTTP, and HTTPS traffic
resource "oci_core_security_list" "web_and_ssh_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "always-free-web-ssh-sl"

  # Rule for SSH (Port 22)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Rule for HTTP (Port 80)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Rule for HTTPS (Port 443)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# Creates a Reserved (Static) Public IP address
resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "always-free-reserved-ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.instance_private_ips.private_ips[0].id
}