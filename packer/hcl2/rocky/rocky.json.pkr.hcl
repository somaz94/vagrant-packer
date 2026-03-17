packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "5000"
}

variable "password" {
  type    = string
  default = "vagrant"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "user" {
  type    = string
  default = "vagrant"
}

# Kickstart variables
variable "root_password" {
  type        = string
  default     = "vagrant"
  description = "Root password for the OS installation"
}

variable "timezone" {
  type    = string
  default = "Asia/Seoul"
}

source "qemu" "rocky-os-0.0.1" {
  accelerator      = "kvm"
  boot_command     = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky-ks.cfg<enter><wait>"]
  boot_wait        = "10s"
  disk_interface   = "virtio"
  disk_size        = "${var.disk_size}"
  format           = "qcow2"
  http_content = {
    "/rocky-ks.cfg" = templatefile("${path.root}/http/rocky-ks.cfg.pkrtpl", {
      root_password    = var.root_password
      vagrant_password = var.password
      timezone         = var.timezone
    })
  }
  iso_checksum     = "md5:c4b695afc90daf08d52941cd0cd76c8a"
  iso_url          = "/var/lib/libvirt/images/Rocky-8.6-x86_64-minimal.iso"
  net_device       = "virtio-net"
  output_directory = "output"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.password}'|sudo -S shutdown -P now"
  ssh_password     = "${var.password}"
  ssh_username     = "${var.user}"
  ssh_wait_timeout = "10m"
  vm_name          = "rocky-os-0.0.1"
  vnc_bind_address = "0.0.0.0"
}

build {
  sources = ["source.qemu.rocky-os-0.0.1"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/vagrant.sh", "scripts/cleanup.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "box/rocky-os-0.0.1.box"
  }
}
