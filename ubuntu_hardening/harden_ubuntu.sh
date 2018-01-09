#!/bin/bash
### Ubuntu Hardening Script
### Script for initial Ubunutu Server setup and security hardening
### Tested on Ubuntu Server 16.04.3
### WARNING: This will apply a secure sshd_config that forced public key auth,
###          ensure you have your public keys installed before running this script.

### Setup colors
NORM='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

### Welcome message
echo -e "${GREEN}Starting Ubuntu hardening script...${NORM}"

### Update & Upgrade
echo -e "${GREEN}Updating and upgrading packages...${NORM}"
sudo apt-get -y update && sudo apt-get -y upgrade

### Setup UFW and allow SSH & HTTP/HTTPS
echo -e "${GREEN}Installing UFW and allowing protocols through...${NORM}"
sudo apt-get -y install ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable
sudo ufw status verbose

### Install fail2ban
echo -e "${GREEN}Installing fail2ban...${NORM}"
sudo apt-get -y install fail2ban
echo -e "${GREEN}Copying /etc/fail2ban/jail.conf -> /etc/fail2ban/jail.local.bak${NORM}"
sudo cp -f /etc/fail2ban/jail.conf /etc/fail2ban/jail.local.bak
echo -e "${GREEN}Copying jail.local -> /etc/fail2ban/jail.local${NORM}"
sudo cp -f jail.local /etc/fail2ban/jail.local
echo -e "${GREEN}Copying /etc/fail2ban/fail2ban.conf -> /etc/fail2ban/fail2ban.local.bak${NORM}"
sudo cp -f /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local.bak
echo -e "${GREEN}Copying fail2ban.local -> /etc/fail2ban/fail2ban.local${NORM}"
sudo cp -f fail2ban.local /etc/fail2ban/fail2ban.local
echo -e "${GREEN}Copying nginx-noscript.conf -> /etc/fail2ban/filter.d/nginx-noscript.conf${NORM}"
sudo cp -f nginx-noscript.conf /etc/fail2ban/filter.d/nginx-noscript.conf


### Secure shared memory if not already done
if grep -q "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" /etc/fstab
then
    echo -e "#{YELLOW}Shared memory already secured...${NORM}"
else
    echo -e "${GREEN}Securing shared memory in /etc/fstab...${NORM}"
    sudo sh -c "echo 'tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0' >> /etc/fstab"
fi

### Backup /etc/sysctl.conf file
echo -e "${GREEN}Backing up /etc/sysctl.conf -> /etc/sysctl.conf.bak${NORM}"
sudo cp -f /etc/sysctl.conf /etc/sysctl.conf.bak

### Harden /etc/sysctl.conf - dump this at the end
echo -e "${GREEN}Hardening /etc/sysctl.conf${NORM}"
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
echo -e "${GREEN}Backing up /etc/host.conf -> /etc/host.conf.bak${NORM}"
sudo cp -f /etc/host.conf /etc/host.conf.bak

### Prevent IP spoofing in /etc/host.conf - overwrite file with this
echo -e "${GREEN}Hardening /etc/host.conf${NORM}"
sudo sh -c "echo 'order bind,hosts
nospoof on' > /etc/host.conf"

### Install RKHunter and CHKRootKit
echo -e "${GREEN}Installing RKHunter & CHKRootKit${NORM}"
sudo apt-get -y install rkhunter chkrootkit

### Run CHKRootKit
echo -e "${GREEN}Running chkrootkit...${NORM}"
sudo chkrootkit

### Run RKHunter
echo -e "${GREEN}Running rkhunter...${NORM}"
sudo rkhunter --update ### Update definitions
sudo rkhunter --propupd ### Update entire properties file
sudo rkhunter --check --sk ### Run all checks and skip keypress requirement

### Backup /etc/ssh/sshd_config
echo -e "${GREEN}Backing up SSH configuration...${NORM}"
sudo cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

### Warn about public keys before applying ssh config and give some delay to bail
echo -e "${RED}WARNING: This sshd_config file will restric access to public keys only! Ensure your public keys are on this box before proceeding!${NORM}"
sleep 10

### Apply new sshd_config
echo -e "${GREEN}Applying new SSH configuration...${NORM}"
sudo cp -f sshd_config /etc/ssh/sshd_config

### Backup /etc/issue.net
echo -e "${GREEN}Backing up /etc/issue.net -> /etc/issue.net.bak${NORM}"
sudo cp -f /etc/issue.net /etc/issue.net.bak

### Apply new banner
echo -e "${GREEN}Applying new login banner...${NORM}"
sudo sh -c "echo '
|**********************************|
|* UNAUTHORIZED ACCESS PROHIBITED *|
|**********************************|
|****** ALL ACTIVITY LOGGED *******|
|**********************************|
' > /etc/issue.net"

### Restart ssh service
echo -e "${GREEN}Restarting SSH service...${NORM}"
sudo service ssh restart

### Complete
echo -e "${GREEN}Ubuntu hardening script completed!${NORM}"

### Housekeeping
### Don't forget to adjust any host specific parameters following the execution of this script
### Example: edit /etc/ssh/sshd_config to add AllowUsers user@sub.net.work.*
