# swap nginx config back to http to renew lets encrypt certificate
# cert and temp webroot should already exist

# remove existing symlink enabling https site
sudo rm /etc/nginx/sites-enabled/$site_name

# apply old http site config to temp webroot
sudo ln -s /etc/nginx/sites-available/$site_name.cert.temp /etc/nginx/sites-enabled/$site_name

# restart nginx
sudo service restart nginx

# renew existing certificate
sudo letsencrypt renew

# remove http symlink
sudo rm /etc/nginx/sites-enabled/$site_name

# apply production config symlink
sudo ln -s /etc/nginx/sites-available/$site_name /etc/nginx/sites-enabled/$site_name

# restart nginx
sudo service restart nginx
