# Data source to get the list of available images for the Always Free tier
data "oci_core_images" "always_free_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


# Creates an Always Free tier compute instance
resource "oci_core_instance" "always_free_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "projects-vm"
  shape               = "VM.Standard.E2.1.Micro"


  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = false # We will attach a reserved IP instead
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.always_free_images.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
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
