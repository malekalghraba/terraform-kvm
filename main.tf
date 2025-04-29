provider "libvirt" {
  uri = "qemu+ssh://malekgh@192.168.1.36/system?keyfile=/home/malekgh/.ssh/malekgh.pem&sshauth=privkey"
}

resource "libvirt_pool" "vm" {
  name = "vm"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "vm-qcow2" {
  name = "vm-qcow2"
  pool = libvirt_pool.vm.name
  source = var.image
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/config/cloud_init.yml")
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.vm.name
}

resource "libvirt_domain" "domain-vm" {
  name   = var.vm_hostname
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
    hostname       = var.vm_hostname
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.vm-qcow2.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]

    
    connection {
      type                = "ssh"
      user                = var.ssh_username
      host                = libvirt_domain.domain-vm.network_interface[0].addresses[0]
      private_key         = file(var.ssh_private_key)
      bastion_host        = "192.168.1.36"
      bastion_user        = "malekgh"
      bastion_private_key = file("/home/malekgh/.ssh/malekgh.pem")
      timeout             = "2m"
    }
  }

depends_on = [libvirt_domain.domain-vm]
  
}
