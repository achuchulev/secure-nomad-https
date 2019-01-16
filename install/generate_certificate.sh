#!/usr/bin/env bash

echo "Generating SSL Certificate for nginx with Certbot...."

EMAIL=atanas.v4@gmail.com
DOMAIN_NAME=test.ntry.site

sudo certbot --nginx --non-interactive --agree-tos -m ${EMAIL} -d ${DOMAIN_NAME} --redirect
