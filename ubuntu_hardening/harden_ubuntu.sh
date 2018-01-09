### Script for initial Ubunutu Server setup and security hardening
### Tested on Ubuntu Server 16.04.3

### Update & Upgrade
echo "Updating and upgrading..."
sudo apt-get -y update && sudo apt-get -y upgrade

### Setup UFW and allow SSH & HTTP/HTTPS
echo "Installing UFW..."
sudo apt-get -y install ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable
sudo ufw status verbose

### Secure shared memory if not already done
if grep -q "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" /etc/fstab
then
    echo "Shared memory already secured..."
else
    echo "Securing shared memory in /etc/fstab..."
    sudo sh -c "echo 'tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0' >> /etc/fstab"
fi

### Backup /etc/sysctl.conf file
sudo cp -f /etc/sysctl.conf /etc/sysctl.conf.bak

### Harden /etc/sysctl.conf - dump this at the end
sudo sh -c "echo '
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0 
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Log Martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv6.conf.default.accept_redirects = 0

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1' >> /etc/sysctl.conf"

### Backup /etc/host.conf file
sudo cp -f /etc/host.conf /etc/host.conf.bak

### Prevent IP spoofing in /etc/host.conf - overwrite file with this
sudo sh -c "echo 'order bind,hosts
multi on
nospoof on' > /etc/host.conf"

### Install RKHunter and CHKRootKit
sudo apt-get -y install rkhunter chkrootkit

### Run CHKRootKit
sudo chkrootkit

### Run RKHunter
sudo rkhunter --update ### Update definitions
sudo rkhunter --propupd ### Update entire properties file
sudo rkhunter --check --sk ### Run all checks and skip keypress requirement

### Backup /etc/ssh/sshd_config
sudo cp -y /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

### Apply new sshd_config
sudo cp -y sshd_config /etc/ssh/sshd_config
