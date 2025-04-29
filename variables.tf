variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/opt/kvm/pool1"
}

variable "image" {
  default = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1601.qcow2"
  type = string
  description = "Source qcow2 base image URL"
}


variable "vm_hostname" {
  description = "vm hostname"
  default     = "terraform-kvm"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default     = "malekgh"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "/home/malekgh/.ssh/id_rsa"
}
