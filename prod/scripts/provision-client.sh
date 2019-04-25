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

# Install Docker required for Nomad docker driver
which docker &>/dev/null || {
  apt update
  apt install docker.io -y
  sudo usermod -G docker -a ubuntu
}

# Check that docker is working
docker run hello-world &>/dev/null && echo docker hello-world works

cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
install nomad /usr/bin/nomad
mkdir -p /etc/nomad.d
chmod 700 /etc/nomad.d
touch /etc/nomad.d/nomad.hcl

# Enable Nomad's CLI command autocomplete support
nomad -autocomplete-install

cat <<EOF > /etc/nomad.d/nomad.hcl

data_dir  = "/opt/nomad"

region = "$1"

datacenter = "$2"

bind_addr = "0.0.0.0"

# advertise {
#   # This should be the IP of THIS MACHINE and must be routable by every node
#   # in your cluster
#   rpc = "{{ GetInterfaceIP \"eth0\" }}"
# }

client {
  enabled = true
  server_join {
    retry_join = ["$4"]
    retry_max = 5
    retry_interval = "15s"
  }
  options = {
    "driver.whitelist" = ""
  }
}
EOF
