# Vagrant & Packer Collection

![License](https://img.shields.io/github/license/somaz94/vagrant-packer)![Latest Tag](https://img.shields.io/github/v/tag/somaz94/vagrant-packer)

A collection of infrastructure-as-code configurations for building machine images with Packer and managing virtual machines with Vagrant.

<br/>

## Features

- **Packer Templates**: HCL2 and JSON templates for building VM images
- **Multi-Platform**: CentOS 7, Rocky Linux 8.6, Ubuntu 20.04 (GCE), Amazon Linux 2 (AWS)
- **Multi-Provider**: KVM/QEMU (local), GCP, AWS
- **Vagrant Configs**: Multi-node cluster provisioning with libvirt
- **Automated Setup**: Kickstart files for unattended OS installation
- **Security Hardening**: PAM, SSH, account lockout, login banners, command logging
- **VM Lifecycle**: Shell scripts for managing VM snapshots, start/stop, rebuild

<br/>

## Project Structure

```
vagrant-packer/
├── packer/
│   ├── hcl2/                    # Modern Packer HCL2 templates
│   │   ├── centos/              # CentOS 7 (QEMU/KVM)
│   │   ├── rocky/               # Rocky Linux 8.6 (QEMU/KVM)
│   │   ├── ubuntu-gce/          # Ubuntu 20.04 (GCP)
│   │   └── amazon-linux/        # Amazon Linux 2 (AWS)
│   └── json/                    # Legacy JSON templates (deprecated)
│       ├── centos/
│       ├── rocky/
│       ├── ubuntu-gce/
│       └── amazon-linux/
├── vagrant/
│   ├── shared/                  # Common init functions & network config
│   ├── somaz-v1/                # Full cluster (11 nodes)
│   ├── somaz-v2/                # Compact cluster (6 nodes)
│   └── somaz-v3/                # Minimal cluster (4 nodes)
├── docs/                        # Detailed guides
├── .github/workflows/           # GitHub Actions
├── cliff.toml                   # git-cliff changelog config
└── LICENSE
```

<br/>

## Quick Start

### Build a VM Image with Packer

```bash
cd packer/hcl2/rocky
cp rocky.auto.pkrvars.hcl.example rocky.auto.pkrvars.hcl
# Edit rocky.auto.pkrvars.hcl with your values
packer init .
packer build rocky.json.pkr.hcl
```

### Start a Vagrant Cluster

```bash
cd vagrant/somaz-v3
vagrant up
```

### Manage VM Lifecycle

```bash
./somazenv.sh status    # Show all VM status
./somazenv.sh start     # Start or create VMs
./somazenv.sh stop      # Graceful halt
./somazenv.sh rebuild   # Destroy and recreate all VMs
```

<br/>

## Documentation

| Guide | Description |
|---|---|
| [Installation Guide](docs/installation.md) | Prerequisites, Vagrant/Packer/KVM setup, cloud provider config |
| [Packer Guide](docs/packer-guide.md) | Build VM images for QEMU, GCE, AWS with variables and kickstart |
| [Vagrant Guide](docs/vagrant-guide.md) | Multi-node cluster configs, networking, provisioning, resources |

<br/>

## Reference

- [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)
- [Packer Documentation](https://developer.hashicorp.com/packer/docs)
- [Packer: Migrate to HCL2](https://developer.hashicorp.com/packer/tutorials/configuration-language/hcl2-upgrade)
- [Enable Nested Virtualization in KVM](https://ostechnix.com/how-to-enable-nested-virtualization-in-kvm-in-linux/)

<br/>

## Contributing

Issues and pull requests are welcome.

<br/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
