#!/usr/bin/env bash

echo "Configuring nginx...."

# stop nginx service
sudo systemctl stop nginx.service

# remove default conf of nginx
[ -f /etc/nginx/sites-available/default ] && {
 sudo rm -fr /etc/nginx/sites-available/default
}

# copy our nginx conf
sudo cp ~/nginx.conf /etc/nginx/sites-available/default

# start nginx service
sudo systemctl start nginx.service
