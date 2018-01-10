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

### Copy nginx.conf
echo -e "${GREEN}Copying nginx.conf -> /etc/nginx/nginx.conf${NORM}"
sudo cp -f nginx.conf /etc/nginx/nginx.conf

### Prompt for name of site
echo -e "${GREEN}Please enter domain name for nginx site (ex: domain.com): ${NORM}"
read my_domain

### Copy site, pre-SSL
echo -e "${GREEN}Copying site_example_pre_ssl -> /etc/nginx/sites-available/$my_domain${NORM}"
sudo cp -f site_example_pre_ssl /etc/nginx/sites-available/$my_domain

### Install Let's Encrypt
echo -e "${GREEN}Installing Let's Encrypt${NORM}"
sudo apt-get -y install letsencrypt

### Generate SSL certificate using Let's Encrypt
### Change "site.com" to your actual domain
### Ensure that nginx is already up and running at the correct domain before generating
### This process relies on DNS resolution
echo -e "${GREEN}Generating Let's Encrypt certificate...${NORM}"
letsencrypt certonly --webroot -w /var/www/site.com -d site.com -d www.site.com

### Generate dhparam
echo -e "${GREEN}Generating dhparam.pem...${NORM}"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

### Copy site, post-SSL
echo -e "${GREEN}Copying site_example_post_ssl -> /etc/nginx/sites-available/$my_domain${NORM}"
sudo cp -f site_example_post_ssl /etc/nginx/sites-available/$my_domain

### Restart nginx
echo -e "${GREEN}Restarting nginx service...${NORM}"
sudo service nginx restart

### Finished
echo -e "${GREEN}Nginx configuration script complete!${NORM}"
