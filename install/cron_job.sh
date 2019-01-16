#!/usr/bin/env bash

crontab <<EOF
0 12 * * * /usr/bin/certbot renew --quiet
EOF
