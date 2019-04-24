#!/bin/bash

# Install nomad
echo "Installing Nomad..."

NOMAD_VERSION=0.9.0

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

region = "$4"

datacenter = "$3"

bind_addr = "0.0.0.0"

# advertise {
#   #rpc = "{{ GetInterfaceIP \"eth0\" }}"
#   serf = "{{ GetPublicIP }}"
# }

server {
  enabled = true
  bootstrap_expect = 3
  authoritative_region = "$5"
  server_join {
    retry_join = ["provider=aws tag_key=$1 tag_value=$2"]
    retry_max = 5
    retry_interval = "15s"
  }
}
EOF