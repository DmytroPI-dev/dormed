resource "oci_objectstorage_bucket" "tf_bucket" {
  name           = var.bucket_name
  compartment_id = var.compartment_ocid
  storage_tier   = "Standard"
  namespace      = var.namespace
  access_type    = "NoPublicAccess"

  versioning = "Enabled"
}
