# Defines the required variables for your OCI tenancy and configuration.
# You will create a terraform.tfvars file to provide the values for these.

variable "tenancy_ocid" {
  description = "The OCID of your OCI tenancy."
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user."
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the API key."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file."
  type        = string
}

variable "region" {
  description = "The OCI region to create the resources in."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment to create resources in."
  type        = string
}

variable "ssh_public_key" {
  description = "The content of the public SSH key."
  type        = string
}
