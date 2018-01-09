#!/bin/bash
### Nginx Configuration & Hardening Script
### Script for initial Nginx configuration and security hardening
### Tested on Ubuntu Server 16.04 with Nginx 1.12.2
### INFO: Following setup you should configure any site specific parameters within the site conf

### Setup colors
NORM='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

### Welcome message
echo -e "${GREEN}Starting nginx configuration script...${NORM}"

### Update & Upgrade
echo -e "${GREEN}Updating and upgrading packages...${NORM}"
sudo apt-get -y update && sudo apt-get -y upgrade

### Install Let's Encrypt
sudo apt-get -y install letsencrypt

### Generate SSL certificate using Let's Encrypt
### Change "site.com" to your actual domain
letsencrypt certonly --webroot -w /var/www/site.com -d site.com -d www.site.com

### Generate dhparam
openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

### Restart nginx
sudo service nginx restart
