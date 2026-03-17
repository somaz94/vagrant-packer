# Vagrant Guide

This guide covers the multi-node VM cluster configurations managed by Vagrant.

<br/>

## Overview

Three cluster versions are provided, each targeting different deployment scenarios:

| Version | Directory | Nodes | Box Image | Use Case |
|---|---|---|---|---|
| v1 | `vagrant/somaz-v1/` | Control(3), Compute(2), Ceph(3), Network(2), Manage(1) | `somaz-os-0.0.2` | CloudPC-Edu (full cluster) |
| v2 | `vagrant/somaz-v2/` | Control(3), Compute(2), Ceph(1) | `somaz-os-2.0.7` | CloudPC-Edu (compact) |
| v3 | `vagrant/somaz-v3/` | Control(1), Compute(2), Ceph(1) | `somaz-os-2.0.7` | CloudPC-Run (minimal) |

<br/>

## Network Architecture

All versions use multiple libvirt networks for traffic isolation:

| Network | Subnet | Purpose |
|---|---|---|
| service | (management) | Vagrant management network |
| mgmt | `192.168.20.0/24` | Management / API traffic |
| tenant | `192.168.30.0/24` | Tenant overlay network |
| provider | `10.10.40.0/24` | Provider network (auto_config: false) |
| storage | `192.168.50.0/24` | Storage traffic (Ceph client) |
| ceph-cluster | `192.168.60.0/24` or `10.10.60.0/24` | Ceph cluster replication |

<br/>

### IP Allocation Scheme

| Node Type | mgmt IP Range | SSH Port Range |
|---|---|---|
| control | `192.168.20.1x` | `6001x` |
| compute | `192.168.20.10x` | `6010x` |
| network | `192.168.20.15x` | `6015x` |
| ceph | `192.168.20.20x` | `6020x` |
| manage | `192.168.20.5x` | `6005x` |

<br/>

## Usage

<br/>

### Start Cluster

```bash
cd vagrant/somaz-v3
vagrant up
```

<br/>

### VM Lifecycle Management (somazenv.sh)

Each version includes a `somazenv.sh` script for managing the VM lifecycle:

```bash
./somazenv.sh status    # Show all VM status
./somazenv.sh start     # Start or create VMs
./somazenv.sh stop      # Graceful halt
./somazenv.sh stop force # Force stop all VMs
./somazenv.sh rebuild   # Destroy and recreate all VMs
./somazenv.sh revert somaz    # Revert to 'somaz' snapshot
./somazenv.sh revert somazpc  # Revert to 'somazpc' snapshot
```

<br/>

### SSH Access

```bash
# Via Vagrant
vagrant ssh control01

# Via forwarded port
ssh -p 60011 vagrant@127.0.0.1
```

<br/>

## Provisioning Scripts

<br/>

### somaz_init.sh

The main initialization script runs on each node during `vagrant up`. It configures:

- **SSH**: Password auth enabled, StrictHostKeyChecking disabled, UseDNS disabled, session timeout (TMOUT=300)
- **User Setup**: Creates `somaz` user with wheel group (password via `SOMAZ_PASSWORD` env var)
- **DNS**: Populates `/etc/hosts` with all cluster node entries
- **Security Hardening**:
  - PAM: Password complexity (lower, upper, digit), max 90 days, min 7 days, remember 12
  - Account lockout: 5 failed attempts, 1800s unlock timeout
  - SUID bit removal on newgrp, unix_chkpwd
  - su restricted to wheel group
  - Login warning banners (/etc/motd, /etc/issue.net, /etc/banner)
- **Logging**: Command logging via cmdlog, kernel log separation, kubelet log separation, logrotate
- **Kernel Tuning**: Docker parameters, TCP/network tuning, inotify watchers
- **NTP**: chrony configured with control01 as time source
- **Disk**: Partition resize to use full disk

<br/>

### somaz_init1.sh (v1 only)

Enhanced version for v1 clusters with additional:
- Rocky Linux / Burrito project support
- Ceph node SELinux enforcement
- dnf-based package management
- Python3 and epel-release installation

<br/>

## Environment Variables

The provisioning scripts support the following environment variables:

| Variable | Default | Description |
|---|---|---|
| `SOMAZ_PASSWORD` | `changeme` | Password for the somaz user |
| `DOWNLOAD_USER` | `somaz` | Username for package download server |
| `DOWNLOAD_PASSWORD` | (none) | Password for package download server |

Set these in the Vagrantfile or pass them via the shell provisioner environment.

<br/>

## Node Resources

<br/>

### v1 (Full Cluster)

| Node | vCPU | Memory | Disk | Count |
|---|---|---|---|---|
| control | 16 | 96 GB | 500 GB | 3 |
| compute | 16 | 32 GB | 100 GB | 2 |
| ceph | 8 | 32 GB | 100 GB + 3x300 GB | 3 |
| network | 8 | 32 GB | 100 GB | 2 |
| manage | 8 | 32 GB | 100 GB | 1 |

<br/>

### v2 (Compact)

| Node | vCPU | Memory | Disk | Count |
|---|---|---|---|---|
| control | 8 | 96 GB | 500 GB | 3 |
| compute | 16 | 32 GB | default | 2 |
| ceph | 8 | 32 GB | default + 3x300 GB | 1 |

<br/>

### v3 (Minimal)

| Node | vCPU | Memory | Disk | Count |
|---|---|---|---|---|
| control | 8 | 96 GB | 500 GB | 1 |
| compute | 24 | 128 GB | default | 2 |
| ceph | 8 | 32 GB | default + 3x300 GB | 1 |
