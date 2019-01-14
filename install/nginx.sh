#!/usr/bin/env bash

# check if nginx is installed
# install nginx if not installed
  
which nginx || {
  echo No, nginx is not installed
  sudo apt-get update
  sudo apt-get install -y nginx
  }
