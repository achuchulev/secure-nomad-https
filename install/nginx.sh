#!/usr/bin/env bash

# check if nginx is installed
# install nginx if not installed

which nginx || {
  echo "Installing nginx...."
  sudo apt-get update
  sudo apt-get install -y nginx
}
