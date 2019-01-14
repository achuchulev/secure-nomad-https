#!/usr/bin/env bash

# stop nginx service
sudo systemctl stop nginx.service

# remove default conf of nginx
[ -f /etc/nginx/sites-available/default ] && {
 sudo rm -fr /etc/nginx/sites-available/default
}

# copy our nginx conf
sudo cp /vagrant/nginx/nginx.conf /etc/nginx/sites-available/default

# start nginx service
sudo systemctl start nginx.service

# check status of nginx service
systemctl status nginx.service
