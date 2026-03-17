packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "account_file" {
  type        = string
  description = "Path to GCP service account JSON key file"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "source_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "zone" {
  type    = string
  default = "asia-northeast3-a"
}

variable "password" {
  type      = string
  sensitive = true
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "googlecompute" "ubuntu-golden" {
  account_file        = "${var.account_file}"
  disk_size           = "10"
  disk_type           = "pd-ssd"
  image_description   = "Ubuntu Golden Image"
  image_name          = "ubuntu-golden-image-${local.timestamp}"
  machine_type        = "${var.machine_type}"
  network             = "default"
  project_id          = "${var.project_id}"
  source_image_family = "${var.source_image_family}"
  ssh_username        = "ubuntu"
  subnetwork          = "default"
  tags                = ["ubuntu", "golden-image"]
  use_internal_ip     = false
  zone                = "${var.zone}"
}

build {
  sources = ["source.googlecompute.ubuntu-golden"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/ubuntu-setup.sh"]
  }
}
