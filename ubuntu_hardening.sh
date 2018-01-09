# Script for initial Ubunutu Server setup and security hardening
# Tested on Ubuntu Server 16.04.3

# Update & Upgrade
echo "Updating and upgrading..."
sudo apt-get -y update && sudo apt-get -y upgrade

# Setup UFW and allow SSH & HTTP/HTTPS
echo "Installing UFW..."
sudo apt-get -y install ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable
sudo ufw status verbose

# Secure shared memory if not already done
if grep -q "tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0" /etc/fstab
then
    echo "Shared memory already secured..."
else
    echo "Securing shared memory in /etc/fstab..."
    sudo sh -c "echo 'tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0' >> /etc/fstab"
fi
