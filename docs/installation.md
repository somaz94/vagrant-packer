# Installation Guide

<br/>

## Prerequisites

<br/>

### Enable Nested Virtualization

Required for running KVM/QEMU on a virtual machine host.

- [Enable Nested Virtualization in KVM](https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/)

Check if nested virtualization is enabled:

```bash
# Intel
cat /sys/module/kvm_intel/parameters/nested

# AMD
cat /sys/module/kvm_amd/parameters/nested
```

<br/>

## Vagrant

<br/>

### CentOS/RHEL

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vagrant
sudo yum -y install qemu libvirt libvirt-devel ruby-devel gcc qemu-kvm libguestfs-tools
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
```

<br/>

### Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
```

<br/>

### Verify Installation

```bash
vagrant --version
vagrant plugin list
```

<br/>

## Packer

<br/>

### CentOS/RHEL

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

<br/>

### Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

### Verify Installation

```bash
packer --version
```

<br/>

## KVM Storage Pool (Optional)

Create a dedicated libvirt storage pool for Vagrant VMs on a separate disk:

```bash
# Format the disk
mkfs.xfs /dev/sdb1

# Create mount point
mkdir -p /var/lib/libvirt/vagrant

# Add to fstab
echo "$(blkid /dev/sdb1 -o export | grep ^UUID) /var/lib/libvirt/vagrant xfs defaults 0 0" >> /etc/fstab
mount -a

# Define and start the libvirt pool
virsh pool-define-as --name vagrant --type dir --target /var/lib/libvirt/vagrant
virsh pool-start vagrant
virsh pool-autostart vagrant
```

<br/>

### Verify Pool

```bash
virsh pool-list --all
virsh pool-info vagrant
```

<br/>

## Cloud Provider Setup

<br/>

### AWS (for Amazon Linux Packer builds)

Configure AWS credentials:

```bash
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="ap-northeast-2"
```

<br/>

### GCP (for Ubuntu GCE Packer builds)

1. Create a service account with `Compute Instance Admin` role
2. Download the JSON key file
3. Pass the key file path to Packer via the `account_file` variable
