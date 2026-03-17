# Packer Guide

This guide covers building VM images using the Packer templates in this repository.

<br/>

## Overview

The repository provides Packer templates in two formats:
- **HCL2** (`packer/hcl2/`) - Modern, recommended format with `templatefile()` for kickstart variable injection
- **JSON** (`packer/json/`) - Legacy format, deprecated (see `packer/json/README.md`)

Each HCL2 template includes a `*.auto.pkrvars.hcl.example` file. Copy it to `*.auto.pkrvars.hcl` and fill in your values before building.

<br/>

## Supported Platforms

| Platform | Provider | Format | Directory |
|---|---|---|---|
| CentOS 7 | QEMU/KVM | raw | `packer/hcl2/centos/` |
| Rocky Linux 8.6 | QEMU/KVM | qcow2 | `packer/hcl2/rocky/` |
| Ubuntu 20.04 | Google Compute Engine | GCE Image | `packer/hcl2/ubuntu-gce/` |
| Amazon Linux 2 | AWS EBS | AMI | `packer/hcl2/amazon-linux/` |

<br/>

## CentOS / Rocky Linux (QEMU/KVM)

<br/>

### Prerequisites

- QEMU/KVM installed and configured
- ISO images placed in `/var/lib/libvirt/images/`
  - CentOS: `CentOS-7-x86_64-Minimal-2009.iso`
  - Rocky: `Rocky-8.6-x86_64-minimal.iso`

<br/>

### Build

```bash
cd packer/hcl2/centos
cp centos.auto.pkrvars.hcl.example centos.auto.pkrvars.hcl
# Edit centos.auto.pkrvars.hcl (set admin_password at minimum)
packer init .
packer build centos.json.pkr.hcl
```

```bash
cd packer/hcl2/rocky
cp rocky.auto.pkrvars.hcl.example rocky.auto.pkrvars.hcl
packer init .
packer build rocky.json.pkr.hcl
```

<br/>

### Variables

| Variable | Default | Description |
|---|---|---|
| `cpu` | `2` | Number of vCPUs |
| `ram` | `2048` | Memory in MB |
| `disk_size` | `5000` | Disk size in MB |
| `user` | `vagrant` | SSH username |
| `password` | `vagrant` | SSH password |
| `root_password` | `vagrant` | Root password for kickstart |
| `admin_user` | `somaz` | Admin user created during install (CentOS only) |
| `admin_password` | (required, sensitive) | Admin user password (CentOS only) |
| `timezone` | `Asia/Seoul` | System timezone |

Kickstart files (`http/*.cfg.pkrtpl`) are rendered at build time using Packer's `templatefile()` function, so credentials are never stored in the repository.

<br/>

### Output

- CentOS: `box/centos-os-0.0.1_raw.box` (Vagrant box, raw format)
- Rocky: `box/rocky-os-0.0.1.box` (Vagrant box, qcow2 format)

<br/>

### Kickstart Files

Unattended OS installation is configured via kickstart files in `http/` directory:
- `centos-ks.cfg` - CentOS 7 kickstart with LVM partitioning
- `centos-ks-v2.cfg` - Enhanced version with security hardening
- `rocky-ks.cfg` - Rocky Linux 8.6 kickstart with LVM partitioning

<br/>

## Ubuntu 20.04 (Google Compute Engine)

<br/>

### Prerequisites

- GCP service account JSON key file
- GCP project with Compute Engine API enabled

<br/>

### Build

```bash
cd packer/hcl2/ubuntu-gce
packer init .
packer build \
  -var "account_file=/path/to/service-account.json" \
  -var "project_id=your-gcp-project" \
  -var "password=your-sudo-password" \
  ubuntu-gce.json.pkr.hcl
```

<br/>

### Variables

| Variable | Default | Description |
|---|---|---|
| `account_file` | (required) | Path to GCP service account JSON key |
| `project_id` | (required) | GCP project ID |
| `password` | (required, sensitive) | Sudo password for provisioning |
| `machine_type` | `n1-standard-1` | GCE machine type |
| `source_image_family` | `ubuntu-2004-lts` | Source image family |
| `zone` | `asia-northeast3-a` | GCE zone |

<br/>

### Provisioning

The `scripts/ubuntu-setup.sh` script installs:
- System updates and essential utilities
- kubectl (latest stable version)
- NFS common utilities

<br/>

## Amazon Linux 2 (AWS)

<br/>

### Prerequisites

- AWS credentials configured (`~/.aws/credentials` or environment variables)

<br/>

### Build

```bash
cd packer/hcl2/amazon-linux
packer init .
packer build \
  -var "password=your-sudo-password" \
  amazon-linux.json.pkr.hcl
```

<br/>

### Variables

| Variable | Default | Description |
|---|---|---|
| `instance_type` | `t2.micro` | EC2 instance type |
| `region` | `ap-northeast-2` | AWS region |
| `user` | `ec2-user` | SSH username |
| `password` | (required, sensitive) | Sudo password for provisioning |

<br/>

### Provisioning

The `scripts/package.sh` script installs:
- System updates
- Basic utilities (git, vim, wget, curl)
- Amazon EFS utilities
- kubectl (latest stable version)

<br/>

## Provisioning Scripts

| Script | Used By | Description |
|---|---|---|
| `vagrant.sh` | CentOS, Rocky | Install Vagrant SSH keys |
| `cleanup.sh` | CentOS, Rocky | Clean up network config, disable SELinux, remove temp files |
| `zerodisk.sh` | CentOS, Rocky | Zero out free space to reduce image size |
| `ubuntu-setup.sh` | Ubuntu GCE | Install packages and kubectl |
| `package.sh` | Amazon Linux | Install packages and kubectl |

<br/>

## Migrating from JSON to HCL2

The JSON templates under `packer/json/` are provided for reference. For new builds, use the HCL2 templates. To migrate existing JSON templates:

```bash
packer hcl2_upgrade your-template.json
```

See [Packer: Migrate to HCL2](https://developer.hashicorp.com/packer/tutorials/configuration-language/hcl2-upgrade) for details.
