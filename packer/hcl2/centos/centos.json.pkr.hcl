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

source "qemu" "centos-os-0.0.1" {
  accelerator      = "kvm"
  boot_command     = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-ks.cfg<enter><wait>"]
  boot_wait        = "10s"
  disk_interface   = "virtio"
  disk_size        = "${var.disk_size}"
  format           = "raw"
  http_directory   = "http"
  iso_checksum     = "md5:a4711c4fa6a1fb32bd555fae8d885b12"
  iso_url          = "/var/lib/libvirt/images/CentOS-7-x86_64-Minimal-2009.iso"
  net_device       = "virtio-net"
  output_directory = "output"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [["-m", "${var.ram}M"], ["-smp", "${var.cpu}"]]
  shutdown_command = "echo '${var.password}'|sudo -S shutdown -P now"
  ssh_password     = "${var.password}"
  ssh_username     = "${var.user}"
  ssh_wait_timeout = "10m"
  vm_name          = "centos-os-0.0.1"
  vnc_bind_address = "0.0.0.0"
}

build {
  sources = ["source.qemu.centos-os-0.0.1"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/vagrant.sh", "scripts/cleanup.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "box/centos-os-0.0.1_raw.box"
  }
}
