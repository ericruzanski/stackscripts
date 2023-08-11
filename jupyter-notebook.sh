#!/bin/bash

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

## Install Python and Notebook
sudo apt-get install python3-pip python3-dev python3-venv -y
sudo python3 -m pip install notebook

# Generate and configure the default Jupyter Notebook config
jupyter notebook --generate-config
CONFIG_FILE="/root/.jupyter/jupyter_notebook_config.py"
mkdir /opt/notebooks
HASHED_PASSWORD=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('${NOTEBOOK_PASSWORD}'))")
sudo tee -a $CONFIG_FILE <<EOF
c.NotebookApp.notebook_dir = '/opt/notebooks'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'$HASHED_PASSWORD'
c.NotebookApp.allow_origin = '*'
c.NotebookApp.allow_root = True
c.NotebookApp.trust_xheaders = True
EOF

## Install NGINX 
apt install nginx -y 

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
apt install python3-certbot-nginx -y 
certbot run --non-interactive --nginx --agree-tos --redirect -d ${ABS_DOMAIN} -m ${SOA_EMAIL_ADDRESS} -w /var/www/html/

## Start Jupyter Notebook
jupyter notebook

## Cleanup
stackscript_cleanup