# Terraform OCI Always Free VM

This set of Terraform files will create a virtual machine and all the required networking infrastructure in your Oracle Cloud Infrastructure tenancy, specifically using the "Always Free" tier resources.

---

## ► Prerequisites

1.  An Oracle Cloud Infrastructure account.
2.  Terraform installed on your local machine.
3.  OCI CLI configured with your user credentials (or you can manually create an API key).

---

## ► Setup

### 1. Get the Files

Clone or download these files into a new directory on your local machine.

### 2. Create an API Key

- Go to your **User Settings** in the OCI console.
- Click on **API Keys** and then **Add API Key**.
- Generate a new key pair and download the private key.
- Copy the public key and paste it into the text box in the console.
- Take note of the `tenancy_ocid`, `user_ocid`, and `fingerprint` from the configuration file preview.

### 3. Create `terraform.tfvars` file

In the same directory as the other `.tf` files, create a new file named `terraform.tfvars`. Add the following content, replacing the placeholder values with your own:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..your_tenancy_ocid"
user_ocid        = "ocid1.user.oc1..your_user_ocid"
fingerprint      = "your_api_key_fingerprint"
private_key_path = "/path/to/your/private_key.pem"
region           = "us-ashburn-1" # Or your home region
compartment_ocid = "ocid1.compartment.oc1..your_compartment_ocid"
ssh_public_key   = "ssh-rsa AAAA..." # Your public SSH key
```

> **Note:** For the `compartment_ocid`, you can use your root compartment OCID (which is the same as your tenancy OCID) or create a new compartment.

---

## ► Usage

1.  **Initialize Terraform**
    Open a terminal in the directory where you saved the files and run:
    ```sh
    terraform init
    ```

2.  **Plan the Deployment**
    This will show you all the resources that Terraform will create.
    ```sh
    terraform plan
    ```

3.  **Apply the Configuration**
    Terraform will ask for confirmation. Type `yes` to proceed.
    ```sh
    terraform apply
    ```

Once the process is complete, Terraform will output the public IP address of your new VM. You can then SSH into it using the private key that corresponds to the public key you provided:

```sh
ssh opc@<your_instance_public_ip> -i /path/to/your/private_key.pem
```

---

## ► Cleanup

To destroy all the resources created by this Terraform configuration, run:

```sh
terraform destroy
