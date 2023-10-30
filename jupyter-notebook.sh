#!/bin/bash
################################################################################
# Script: jupyter-notebook.sh
# Author: Eric Ruzanski
# Description: This script installs and configures the classic Jupyter Notebook,
#              serves it securely via an Nginx reverse proxy, and makes it 
#              accessible through a web browser via the provided domain or 
#              default reverse DNS (rDNS) of the Linode. If the Linode is ever 
#              rebooted, or Jupyter Notebook stops running, simply start 
#              Jupyter Notebook from the command line using 'jupyter notebook &'.
#
# GitHub Repository:
# https://github.com/ericruzanski/StackScripts/blob/main/jupyter-notebook.sh
#
# Disclaimer: This script is provided as-is without any warranties.
################################################################################

## Jupyter Notebook Settings
#<UDF name="notebook_password" label="Jupyter Notebook Password" example="s3cure_p4ssw0rd">
#<UDF name="soa_email_address" label="Email address (for the Let's Encrypt SSL certificate)" example="user@domain.tld">

## Linode/SSH Security Settings
#<UDF name="username" label="The limited sudo user to be created for the Linode" default="">
#<UDF name="password" label="The password for the limited sudo user" example="an0th3r_s3cure_p4ssw0rd" default="">
#<UDF name="pubkey" label="The SSH Public Key that will be used to access the Linode" default="">
#<UDF name="disable_root" label="Disable root access over SSH?" oneOf="Yes,No" default="No">

## Domain Settings
#<UDF name="token_password" label="Your Linode API token. This is needed to create your server's DNS records" default="">
#<UDF name="subdomain" label="Subdomain" example="The subdomain for the DNS record: www (Requires Domain)" default="">
#<UDF name="domain" label="Domain" example="The domain for the DNS record: example.com (Requires API token)" default="">

## Enable logging
set -x
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1

## Import the Bash StackScript Library
source <ssinclude StackScriptID=1>

## Import the DNS/API Functions Library
source <ssinclude StackScriptID=632759>

## Import the OCA Helper Functions
source <ssinclude StackScriptID=401712>

## Run initial configuration tasks (DNS/SSH stuff, etc...)
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

## Add UFW rules 
ufw allow http
ufw allow https
ufw allow 8888

## Prepare the Python venv
apt-get install python3-venv python3-pip -y
mkdir /root/jupyter-notebook
mkdir /opt/notebooks
python3 -m venv /root/jupyter-notebook
source /root/jupyter-notebook/bin/activate
python3 -m pip install notebook

# Configure Jupyter Notebook
jupyter notebook --generate-config
CONFIG_FILE="/root/.jupyter/jupyter_notebook_config.py"
HASHED_PASSWORD=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('$NOTEBOOK_PASSWORD'))")
sudo tee -a $CONFIG_FILE <<EOF
c.NotebookApp.notebook_dir = '/opt/notebooks'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'$HASHED_PASSWORD'
c.NotebookApp.allow_origin = '*'
c.NotebookApp.allow_root = True
c.NotebookApp.trust_xheaders = True
EOF

deactivate

## Install NGINX 
apt-get install nginx -y 

# Configure NGINX reverse proxy
rm /etc/nginx/sites-enabled/default
touch /etc/nginx/sites-available/reverse-proxy.conf
cat <<END > /etc/nginx/sites-available/reverse-proxy.conf
server {
        listen 80;
        server_name ${ABS_DOMAIN};
        access_log /var/log/nginx/reverse-access.log;
        error_log /var/log/nginx/reverse-error.log;
        location /wss/ {
                proxy_pass http://127.0.0.1:8888;
                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_read_timeout 86400;
  }
        location /api/kernels/ {
                proxy_pass http://127.0.0.1:8888;
                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_read_timeout 86400;
  }
        location /terminals/ {
                proxy_pass http://127.0.0.1:8888;
                proxy_http_version 1.1;
                proxy_buffering off;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_read_timeout 86400;
  }
        location / {
                proxy_pass http://127.0.0.1:8888;
  }
}
END
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

# Enable and start NGINX
systemctl enable nginx
systemctl restart nginx

sleep 90

## Configure SSL
apt-get install python3-certbot-nginx -y 
certbot run --non-interactive --nginx --agree-tos --redirect -d ${ABS_DOMAIN} -m ${SOA_EMAIL_ADDRESS} -w /var/www/html/

## Cleanup
stackscript_cleanup

## Start Jupyter Notebook
source /root/jupyter-notebook/bin/activate
jupyter notebook
