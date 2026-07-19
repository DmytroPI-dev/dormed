output "a1_instance_private_ip" {
  description = "The private IP address of the A1 private instance."
  value       = data.oci_core_private_ips.a1_instance_private_ips.private_ips[0].ip_address
}

output "a1_instance_ssh_command" {
  description = "SSH command for connecting to the private A1 instance through the existing public VM."
  value       = "ssh -J ubuntu@${oci_core_public_ip.reserved_ip.ip_address} opc@${data.oci_core_private_ips.a1_instance_private_ips.private_ips[0].ip_address}"
}
