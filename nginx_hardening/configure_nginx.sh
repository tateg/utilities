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

### Backup nginx.conf
echo -e "${GREEN}Backing up nginx.conf...${NORM}"
sudo cp -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

### Stop nginx
echo -e "${GREEN}Stopping nginx...${NORM}"
sudo service nginx stop

### Copy nginx.conf
echo -e "${GREEN}Copying nginx.conf -> /etc/nginx/nginx.conf${NORM}"
sudo cp -f nginx.conf /etc/nginx/nginx.conf

### Remove default symlink if it is there
if [ ! -h /etc/nginx/sites-enabled/default ]; then
  echo -e "${GREEN}Default nginx site not enabled...${NORM}"
else
  echo -e "${RED}Disabling default nginx site...${NORM}"
  sudo rm /etc/nginx/sites-enabled/default
fi

### Prompt for name of site
printf "${YELLOW}Please enter domain name for nginx site (ex: domain.com): ${NORM}"
read my_domain
echo -e "${GREEN}Using: ${YELLOW}$my_domain${NORM}"

### Copy site and replace domain in destination, pre-SSL
echo -e "${GREEN}Copying site_example_pre_ssl -> /etc/nginx/sites-available/$my_domain${NORM}"
sudo cp -f site_example_pre_ssl /etc/nginx/sites-available/$my_domain
sudo sed -i -e "s/my_site.com/$my_domain/g" /etc/nginx/sites-available/$my_domain

### Apply symlink to enable site
echo -e "${GREEN}Enabling $my_domain with symlink in /etc/nginx/sites-enabled${NORM}"
sudo ln -s /etc/nginx/sites-available/$my_domain /etc/nginx/sites-enabled/$my_domain

### Setup temporary webroot directory for cert generation and make index
sudo mkdir -p /var/www/$my_domain.cert.temp
sudo sh -c "echo '<h1>temp</h1>' > /var/www/$my_domain.cert.temp/index.html"

### Restart nginx
echo -e "${GREEN}Starting nginx...${NORM}"
sudo service nginx start

### Install Let's Encrypt
echo -e "${GREEN}Installing Let's Encrypt${NORM}"
sudo apt-get -y install letsencrypt

### Generate SSL certificate using Let's Encrypt
### This will generate a temporary webroot that matches the one in the pre_ssl config
### This process relies on DNS resolution so your domain must actually point to this nginx server
echo -e "${GREEN}Generating Let's Encrypt certificate...${NORM}"
printf "${YELLOW}Please enter an email address to use for Let's Encrypt certificate: ${NORM}"
read my_email
echo -e "${GREEN}Using: ${YELLOW}$my_email"
sudo letsencrypt certonly --emailaddress $my_email --webroot -w /var/www/$my_domain.cert.temp -d $my_domain -d www.$my_domain

### Generate dhparam
echo -e "${GREEN}Generating dhparam.pem...${NORM}"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096

### Stop nginx
echo -e "${GREEN}Stopping nginx...${NORM}"
sudo service nginx stop

### Copy site and replace domain in destination, post-SSL
echo -e "${GREEN}Copying site_example_post_ssl -> /etc/nginx/sites-available/$my_domain${NORM}"
sudo cp -f site_example_post_ssl /etc/nginx/sites-available/$my_domain
sudo sed -i -e "s/my_site.com/$my_domain/g" /etc/nginx/sites-available/$my_domain

### Start nginx
echo -e "${GREEN}Starting nginx...${NORM}"
sudo service nginx start

### Finished
echo -e "${GREEN}Nginx configuration script complete!${NORM}"
