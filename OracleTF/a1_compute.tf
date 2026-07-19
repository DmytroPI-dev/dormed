data "oci_core_images" "a1_always_free_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Creates an Always Free-eligible Ampere A1 Flex instance without a public IP
resource "oci_core_instance" "a1_private_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "a1-private-vm"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
    display_name     = "a1-private-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.a1_always_free_images.images[0].id
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
    ]
  }
}

# Data source to find the private VNIC of the A1 instance
data "oci_core_vnic_attachments" "a1_instance_vnics" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.a1_private_instance.id
}

# Data source to find the private IP associated with the A1 VNIC
data "oci_core_private_ips" "a1_instance_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.a1_instance_vnics.vnic_attachments[0].vnic_id
}
