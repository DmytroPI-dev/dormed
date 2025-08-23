output "instance_public_ip" {
  description = "The reserved public IP address of the instance."
  value       = oci_core_public_ip.reserved_ip.ip_address
}
