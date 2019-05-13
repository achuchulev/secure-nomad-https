#!/bin/bash

systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service
# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

# Make sure apt repository db is up to date
export DEBIAN_FRONTEND=noninteractive

# Install tools
echo "Installing tools..."

# Make sure apt repository db is up to date
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

# Install Docker required for Nomad docker driver
sudo apt-get install docker.io -y
sudo usermod -G docker -a ubuntu

# Check that docker is working
sudo docker run hello-world &>/dev/null && echo docker hello-world works
