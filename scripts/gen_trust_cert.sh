#!/usr/bin/env bash

# Generate public trusted certificate for nginx
echo "Generating SSL Certificate for nginx with Certbot...."

# Specify your email and dns details here!
EMAIL=atanas.v4@gmail.com
DOMAIN_NAME=access.ntry.site
sudo certbot --nginx --non-interactive --agree-tos -m ${EMAIL} -d ${DOMAIN_NAME} --redirect

# Create cron job to check and renew public certificate on expiration
crontab <<EOF
0 12 * * * /usr/bin/certbot renew --quiet
EOF