#!/usr/bin/env bash

# check if nginx is installed
# install nginx if not installed
  
which nginx || {
  echo No, nginx is not installed
  apt-get update
  apt-get install -y nginx
  }
