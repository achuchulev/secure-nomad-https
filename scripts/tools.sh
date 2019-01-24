#!/bin/bash

# Install tools
echo "Installing tools..."

# Make sure apt repository db is up to date
sudo apt-get update

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

# Install Docker required for Nomad docker driver
sudo apt-get install --no-install-recommends -y docker.io
sudo usermod -G docker -a ubuntu

# Check that docker is working
sudo docker run hello-world &>/dev/null && echo docker hello-world works
