#!/usr/bin/env bash

# stop nginx service
systemctl stop nginx.service

# remove default conf of nginx
[ -f /etc/nginx/sites-available/default ] && {
  rm -fr /etc/nginx/sites-available/default
}

# copy our nginx conf
cp nginx/nginx.conf /etc/nginx/sites-available/default

# start nginx service
systemctl start nginx.service

# check status of nginx service
systemctl status nginx.service
