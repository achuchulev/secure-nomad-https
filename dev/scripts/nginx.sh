#!/bin/bash

sudo systemctl stop apt-daily.service
sudo systemctl kill --kill-who=all apt-daily.service
# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

# Make sure apt repository db is up to date
export DEBIAN_FRONTEND=noninteractive

# Install nginx
echo "Installing nginx...."

# Check if nginx is installed
# Install nginx if not installed
which nginx &>/dev/null || {
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
