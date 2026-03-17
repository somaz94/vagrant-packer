packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "user" {
  type    = string
  default = "ec2-user"
}

variable "password" {
  type      = string
  sensitive = true
}

data "amazon-ami" "latest" {
  filters = {
    name                = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = "${var.region}"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "amazon-linux2" {
  ami_name         = "amazon-linux2-golden-image ${local.timestamp}"
  force_deregister = true
  instance_type    = "${var.instance_type}"
  region           = "${var.region}"
  source_ami       = "${data.amazon-ami.latest.id}"
  ssh_interface    = "public_ip"
  ssh_username     = "${var.user}"
  tags = {
    Name = "Amazon Linux 2 Golden Image"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-linux2"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/package.sh"]
  }
}
