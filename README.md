# Vagrant & Packer Collection

![License](https://img.shields.io/github/license/somaz94/vagrant-packer)![Latest Tag](https://img.shields.io/github/v/tag/somaz94/vagrant-packer)

A collection of infrastructure-as-code configurations for building machine images with Packer and managing virtual machines with Vagrant.

<br/>

## Features

- **Packer Templates**: HCL2 and JSON templates for building VM images
- **Multi-Platform**: CentOS, Rocky Linux, Ubuntu (GCE), Amazon Linux
- **Multi-Provider**: KVM/QEMU (local), GCP, AWS
- **Vagrant Configs**: Multi-node cluster provisioning with libvirt
- **Automated Setup**: Kickstart files for unattended OS installation
- **VM Lifecycle**: Shell scripts for managing VM snapshots, start/stop, rebuild

<br/>

## Project Structure

```
vagrant-packer/
├── packer/
│   ├── hcl2/                    # Modern Packer HCL2 templates
│   │   ├── centos/              # CentOS 7 (QEMU/KVM)
│   │   ├── rocky/               # Rocky Linux (QEMU/KVM)
│   │   ├── ubuntu-gce/          # Ubuntu 20.04 (GCP)
│   │   └── amazon-linux/        # Amazon Linux 2 (AWS)
│   └── json/                    # Legacy Packer JSON templates
│       ├── centos/
│       ├── rocky/
│       ├── ubuntu-gce/
│       └── amazon-linux/
├── vagrant/
│   ├── somaz-v1/                # Cluster config v1
│   ├── somaz-v2/                # Cluster config v2
│   └── somaz-v3/                # Cluster config v3
│       ├── Vagrantfile          # Multi-node VM definitions
│       ├── net-service.xml      # libvirt network config
│       ├── somazenv.sh          # VM lifecycle management
│       ├── somaz_init.sh        # VM initialization script
│       └── somaz_init1.sh       # Enhanced initialization script
├── .github/workflows/           # GitHub Actions
├── cliff.toml                   # git-cliff changelog config
└── LICENSE
```

<br/>

## Prerequisites

### Enable Nested Virtualization

Required for running KVM/QEMU on a virtual machine host.

- [Enable Nested Virtualization in KVM](https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/)

<br/>

## Vagrant Installation

<br/>

### CentOS/RHEL

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vagrant
sudo yum -y install qemu libvirt libvirt-devel ruby-devel gcc qemu-kvm libguestfs-tools
vagrant plugin install vagrant libvirt
vagrant plugin install vagrant-mutate
vagrant plugin install vagrant-parallels
```

### Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
vagrant plugin install vagrant libvirt
vagrant plugin install vagrant-mutate
vagrant plugin install vagrant-parallels
```

<br/>

## Packer Installation

<br/>

### CentOS/RHEL

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

### Ubuntu/Debian

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

<br/>

## Optional: KVM Storage Pool

Create a dedicated libvirt pool for Vagrant VMs:

```bash
mkfs.xfs /dev/sdb1
mkdir -p /var/lib/libvirt/vagrant
echo "$(blkid /dev/sdb1 -o export | grep ^UUID) /var/lib/libvirt/vagrant xfs default 0 0" >> /etc/fstab
mount -a
virsh pool-define-as --name vagrant --type dir --target /var/lib/libvirt/vagrant
virsh pool-start vagrant
virsh pool-autostart vagrant
```

<br/>

## Reference

- [Vagrant Installation Guide](https://developer.hashicorp.com/vagrant/downloads?product_intent=vagrant)
- [Packer Installation Guide](https://developer.hashicorp.com/packer/downloads)
- [Packer: Migrate to HCL2](https://developer.hashicorp.com/packer/tutorials/configuration-language/hcl2-upgrade)
- [Enable Nested Virtualization](https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/)

<br/>

## Contributing

Issues and pull requests are welcome.

<br/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
