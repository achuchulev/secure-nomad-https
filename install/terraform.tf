#!/bin/bash

echo "Installing Terraform..."

TERRAFORM_VERSION=0.11.11

cd /tmp/
curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
unzip terraform.zip -d /usr/local/bin/ 
terraform --version
