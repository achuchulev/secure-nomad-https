#!/bin/bash

# Install nomad
echo "Installing Nomad..."

NOMAD_VERSION=$5

systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service
# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

# Make sure apt repository db is up to date
export DEBIAN_FRONTEND=noninteractive
apt update

# Packages required for nomad
which curl &>/dev/null || {
  apt update
  apt install -y curl
}

which unzip &>/dev/null || {
  apt update
  apt install -y unzip
}

cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
install nomad /usr/bin/nomad
mkdir -p /etc/nomad.d
chmod 700 /etc/nomad.d
touch /etc/nomad.d/nomad.hcl

# Enable Nomad's CLI command autocomplete support
nomad -autocomplete-install

cat <<EOF >/etc/nomad.d/nomad.hcl

data_dir  = "/opt/nomad"

region = "$1"

datacenter = "$2"

bind_addr = "0.0.0.0"

server {
  enabled = true
  bootstrap_expect = 3
  authoritative_region = "$3"
  server_join {
    retry_join = ["$4"]
    retry_max = 5
    retry_interval = "15s"
  }
}

# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/home/ubuntu/nomad/ssl/nomad-ca.pem"
  cert_file = "/home/ubuntu/nomad/ssl/server.pem"
  key_file  = "/home/ubuntu/nomad/ssl/server-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
EOF