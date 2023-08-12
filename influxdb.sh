#!/bin/bash

## Linode UDF Settings
#<UDF name="soa_email_address" label="Email address (for the Let's Encrypt SSL certificate)" example="user@domain.tld">
#<UDF name="username" label="The limited sudo user to be created for the Linode" default="">
#<UDF name="password" label="The password for the limited sudo user" example="an0th3r_s3cure_p4ssw0rd" default="">
#<UDF name="pubkey" label="The SSH Public Key that will be used to access the Linode" default="">
#<UDF name="disable_root" label="Disable root access over SSH?" oneOf="Yes,No" default="No">

## Enable logging
set -x
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1

## Import the Bash StackScript Library
source <ssinclude StackScriptID=1>

## Import the DNS/API Functions Library
source <ssinclude StackScriptID=632759>

## Import the OCA Helper Functions
source <ssinclude StackScriptID=401712>

## Initial configuration tasks (DNS/SSH stuff, etc...)
source <ssinclude StackScriptID=666912>

## Register default rDNS 
export DEFAULT_RDNS=$(dnsdomainname -A | awk '{print $1}')

## Set absolute domain if any, otherwise use DEFAULT_RDNS
if [[ $DOMAIN = "" ]]; then
  readonly ABS_DOMAIN="$DEFAULT_RDNS"
elif [[ $SUBDOMAIN = "" ]]; then
  readonly ABS_DOMAIN="$DOMAIN"
else
  readonly ABS_DOMAIN="$SUBDOMAIN.$DOMAIN"
fi
create_a_record $SUBDOMAIN $IP $DOMAIN

## Update system, set hostname & install basic security
set_hostname
apt_setup_update
ufw_install
fail2ban_install

# Add UFW rules 
ufw allow http
ufw allow https
ufw allow 8086

# Install InfluxDB
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-amd64.deb
sudo dpkg -i influxdb2-2.7.0-amd64.deb

# Install NGINX and Python (Certbot SSL)
apt install nginx certbot python3-certbot-nginx -y 

# Configure NGINX reverse proxy
rm /etc/nginx/sites-enabled/default
touch /etc/nginx/sites-available/reverse-proxy.conf
cat <<END > /etc/nginx/sites-available/reverse-proxy.conf
server {
        listen 80;
        server_name ${ABS_DOMAIN};
        access_log /var/log/nginx/reverse-access.log;
        error_log /var/log/nginx/reverse-error.log;
        location / {
                proxy_pass http://localhost:8086;
  }
}
END
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

# Enable and start NGINX
systemctl enable nginx
systemctl restart nginx

sleep 90

## Configure SSL
apt install python3-certbot-nginx -y 
certbot run --non-interactive --nginx --agree-tos --redirect -d ${ABS_DOMAIN} -m ${SOA_EMAIL_ADDRESS} -w /var/www/html/

## Cleanup
stackscript_cleanup

# Start influxd
sudo service influxdb start