#!/usr/bin/env bash
# Common initialization functions shared across all Vagrant cluster versions.
# Source this file from version-specific init scripts:
#   source /vagrant/shared/common_init.sh
# or copy it alongside the Vagrantfile and source locally.

configure_ssh() {
  # Disable StrictHostKeyChecking
  sudo sed -i '/StrictHostKeyChecking/a StrictHostKeyChecking no' /etc/ssh/ssh_config

  # Enable password authentication and root login
  sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

  # Disable UseDNS
  sudo sed -i '/UseDNS no/d' /etc/ssh/sshd_config
  sudo sed -i '/#UseDNS/a UseDNS no' /etc/ssh/sshd_config

  # Session timeout
  echo -e "TMOUT=300\nexport TMOUT" | sudo tee -a /etc/profile
  source /etc/profile

  systemctl restart sshd
}

create_admin_user() {
  local username="${1:-somaz}"
  local uid="${2:-1100}"
  adduser "$username" -u "$uid" -G wheel -p $(echo "${SOMAZ_PASSWORD:-changeme}" | openssl passwd -1 -stdin)
}

configure_hosts() {
  local num_control="$1"
  local num_compute="$2"
  local num_ceph="$3"

  for (( i=1; i<=num_control; i++ )); do echo "192.168.20.1$i control0$i" >> /etc/hosts; done
  for (( i=1; i<=num_compute; i++ )); do echo "192.168.20.10$i compute0$i" >> /etc/hosts; done
  for (( i=1; i<=num_ceph; i++ )); do echo "192.168.20.20$i ceph0$i" >> /etc/hosts; done
}

configure_sudoers() {
  sed -i '110 a %wheel        ALL=(ALL)       NOPASSWD: ALL\n' /etc/sudoers
}

configure_ulimits() {
  echo -e "\n*\tsoft\tnofile\t1024000\n*\thard\tnofile\t1024000" | sudo tee -a /etc/security/limits.conf
}

configure_acpi_blacklist() {
  sudo modprobe -r acpi_power_meter 2>/dev/null || true
  cat <<EOF | sudo tee /etc/modprobe.d/acpi_power_meter.conf
blacklist acpi_power_meter
EOF
}

configure_kernel_logs() {
  sudo sed -i '/kern.log/d' /etc/rsyslog.conf
  sudo sed -i '/#kern.*/a kern.*                                                 -/var/log/kern.log' /etc/rsyslog.conf
  sudo systemctl restart rsyslog
}

configure_logrotate_syslog() {
  cat <<EOF | sudo tee /etc/logrotate.d/syslog
/var/log/cron
/var/log/kern.log
/var/log/kubelet.log
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/sulog
/var/log/spooler
{
    missingok
    rotate 24
    weekly
    compress
    sharedscripts
    create 0600 root root
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF
}

configure_login_banner() {
  local banner_text='##########################################################
#                                                        #
#                      Warning!!                         #
#        This system is for authorized users only!!      #
#                                                        #
##########################################################'

  echo "$banner_text" | sudo tee /etc/motd
  echo "$banner_text" | sudo tee /etc/issue.net
  echo "$banner_text" | sudo tee /etc/banner
  sudo sed -i '1iBanner /etc/banner' /etc/ssh/sshd_config
}

configure_cmdlog() {
  cat <<'CMDEOF' | sudo tee /etc/profile.d/cmdlog.sh
function cmdlog
{
f_ip=`who am i | awk '{print $5}'`
cmd=`history | tail -1`
if [ "$cmd" != "$cmd_old" ]; then
  logger -p local1.notice "[1] From_IP=$f_ip, PWD=$PWD, Command=$cmd"
fi
  cmd_old=$cmd
}
trap cmdlog DEBUG
CMDEOF

  sudo sed -i '/cmdlog/d' /etc/rsyslog.conf
  sudo sed -i '/cron.none/i local1.notice\t\t\t\t\t\t/var/log/cmdlog' /etc/rsyslog.conf
  sudo sed -i 's/cron.none/cron.none;local1.none/g' /etc/rsyslog.conf

  cat <<EOF | sudo tee /etc/logrotate.d/cmdlog
/var/log/cmdlog {
    missingok
    minsize 30M
    create 0600 root root
}
EOF

  sudo systemctl restart rsyslog
}

configure_kernel_params() {
  cat <<EOF | sudo tee -a /etc/sysctl.conf
# Docker kernel parameters
fs.may_detach_mounts = 1
net.ipv4.ip_forward = 1
vm.swappiness = 1
vm.overcommit_memory = 1
vm.panic_on_oom = 0
fs.inotify.max_user_watches = 524288
fs.file-max = 2048000
fs.nr_open = 2048000
EOF
}

configure_network_tuning() {
  cat <<EOF | sudo tee /etc/sysctl.d/70-somaznetwork.conf

net.netfilter.nf_conntrack_max = 1000000

net.core.somaxconn=1000
net.ipv4.netdev_max_backlog=5000
net.core.rmem_max=16777216
net.core.wmem_max=16777216

net.ipv4.tcp_rmem=4096 12582912 16777216
net.ipv4.tcp_wmem=4096 12582912 16777216
net.ipv4.tcp_max_syn_backlog=8096
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=10240 65535
net.ipv4.tcp_abort_on_overflow = 1
EOF
}

configure_bash_history() {
  cat <<EOF | sudo tee -a /etc/bashrc
export HISTTIMEFORMAT="%h %d %H:%M:%S "
export HISTSIZE=10000
EOF
}

configure_provider_nic() {
  cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth3
TYPE=Ethernet
BOOTPROTO=none
DEVICE=eth3
ONBOOT=yes
ONPARENT=yes
MTU=1500
EOF
}

configure_chrony_control() {
  sed -i 's/server control01 iburst/local stratum 10/' /etc/chrony.conf
  sed -i 's/#allow 192.168.0.0\/16/allow 192.168.20.0\/24/' /etc/chrony.conf
}

configure_chrony_client() {
  sed -i 's/^server*/#server/g' /etc/chrony.conf
  sed -i '/server 3/a server control01 iburst' /etc/chrony.conf
}

resize_disk() {
  local vg_name="${1:-centos_centos7}"
  parted /dev/vda resizepart 2 100%
  pvresize /dev/vda2
  lvextend -l +100%FREE "/dev/${vg_name}/root"
  xfs_growfs "/dev/${vg_name}/root"
}

disable_local_link() {
  echo "NOZEROCONF=yes" | sudo tee -a /etc/sysconfig/network
}
