
# Creates an Always Free tier compute instance
resource "oci_core_instance" "always_free_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "projects-vm"
  shape               = "VM.Standard.E2.1.Micro"


  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = false # We will attach a reserved IP instead
    display_name     = "projects-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.uk-london-1.aaaaaaaaa4ht2u5ubsdbz4eqbo6gyxyvxzjg7l2iisnojd7dszoc4aa7xfka"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      iptables -F
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
      iptables -P OUTPUT ACCEPT
      iptables -A INPUT -i lo -j ACCEPT
      iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -j ACCEPT
      iptables -A INPUT -p tcp --dport 80 -j ACCEPT
      iptables -A INPUT -p tcp --dport 443 -j ACCEPT
      iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
      iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
    EOF
    )
  }
}

# Data source to get the availability domains in the region
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Data source to find the VNIC (network card) of the instance
data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.always_free_instance.id
}

# Data source to find the private IP associated with the VNIC
data "oci_core_private_ips" "instance_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0].vnic_id
}
