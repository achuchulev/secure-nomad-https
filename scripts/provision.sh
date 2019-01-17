#!/bin/bash

# Stop services tha checking apt is up to date
sudo systemctl stop apt-daily.service
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl stop apt-daily-upgrade.service
sudo fuser -vki /var/lib/dpkg/lock
sudo fuser -vki /var/cache/apt/archives/lock
sudo fuser -vki /var/cache/debconf/config.dat
sudo dpkg --configure -a

# Make sure apt repository db is up to date
sudo apt-get update

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

# Check if nginx is installed
# Install nginx if not installed
which nginx || {
  echo "Installing nginx...."
  sudo apt-get install -y nginx
}

# Configure nginx
echo "Configuring nginx...."
# Stop nginx service
sudo systemctl stop nginx.service
# Remove default conf of nginx
[ -f /etc/nginx/sites-available/default ] && {
 sudo rm -fr /etc/nginx/sites-available/default
}
# Copy our nginx conf
sudo cp ~/nginx.conf /etc/nginx/sites-available/default
# Start nginx service
sudo systemctl start nginx.service

# Install nomad
echo "Installing Nomad..."
NOMAD_VERSION=0.8.6
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
sudo install nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
# Enable Nomad's CLI command autocomplete support
nomad -autocomplete-install

# Install certbot tool
echo "Installing Certbot...."
sudo apt-get install software-properties-common -y
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install python-certbot-nginx -y

# Generate certificate
echo "Generating SSL Certificate for nginx with Certbot...."
EMAIL=you@example.com
DOMAIN_NAME=your.dns.name
sudo certbot --nginx --non-interactive --agree-tos -m ${EMAIL} -d ${DOMAIN_NAME} --redirect

# Create cron job
crontab <<EOF
0 12 * * * /usr/bin/certbot renew --quiet
EOF
