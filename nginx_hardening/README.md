# Nginx Configuration & Security Hardening

This collection of scripts and config files will aid in setting up nginx with a secure SSL configuration using Let's Encrypt.

There are a few caveats with this setup:
- The script must first use a barebones site config for nginx using port 80 in order for Let's Encrypt to reach webroot
- You must already have DNS resolution for your domain setup and pointing towards the server this is being run on
- Nginx must already be installed correctly using APT (https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/)
- You don't have to use Passenger, but the nginx.conf file does enable it for you and expect it to exist

## Articles, Guides & References
- https://letsencrypt.org/
- https://www.stewright.me/2017/01/add-ssl-nginx-site-free-lets-encrypt/
- https://www.upguard.com/blog/how-to-build-a-tough-nginx-server-in-15-steps
