### swap nginx config back to http to renew lets encrypt certificate
### cert and temp webroot should already exist

### Setup colors
NORM='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

### Welcome message
echo -e "${GREEN}Starting letsencrypt certificate renewal script...${NORM}"

### Prompt for name of site
printf "${YELLOW}Please enter domain name for nginx site (ex: domain.com): ${NORM}"
read site_name
echo -e "${GREEN}Using: ${YELLOW}$site_name${NORM}"

### remove existing symlink enabling https site
echo -e "${GREEN}Removing existing site symlink...{NORM}"
sudo rm /etc/nginx/sites-enabled/$site_name

### apply old http site config to temp webroot
echo -e "${GREEN}Applying temporary renewal http site config...{NORM}"
sudo ln -s /etc/nginx/sites-available/$site_name.cert.temp /etc/nginx/sites-enabled/$site_name

### restart nginx
echo -e "${GREEN}Restarting nginx...{NORM}"
sudo service restart nginx

### renew existing certificate
echo -e "${GREEN}Renewing certificate...{NORM}"
sudo letsencrypt renew

### remove http symlink
echo -e "${GREEN}Removing temporary http site symlink...{NORM}"
sudo rm /etc/nginx/sites-enabled/$site_name

### apply production config symlink again
echo -e "${GREEN}Re-applying production site symlink...{NORM}"
sudo ln -s /etc/nginx/sites-available/$site_name /etc/nginx/sites-enabled/$site_name

### restart nginx
echo -e "${GREEN}Restarting nginx...{NORM}"
sudo service restart nginx

echo -e "${GREEN}Done!{NORM}"
