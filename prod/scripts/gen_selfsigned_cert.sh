#!/usr/bin/env bash

# Generate selfsigned certificates for Nomad cluster 
echo "Generating selfsigned SSL Certificate for Nomad cluster...."

mkdir -p ~/nomad/ssl

# Generate the CA's private key and certificate
cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad/ssl/nomad-ca


# Generate a certificate for the Nomad server
echo '{}' | cfssl gencert -ca=nomad/ssl/nomad-ca.pem -ca-key=nomad/ssl/nomad-ca-key.pem -config=cfssl.json \
    -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare nomad/ssl/server


# Generate a certificate for the Nomad client
echo '{}' | cfssl gencert -ca=nomad/ssl/nomad-ca.pem -ca-key=nomad/ssl/nomad-ca-key.pem -config=cfssl.json \
    -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare nomad/ssl/client


# Generate a certificate for the CLI
echo '{}' | cfssl gencert -ca=nomad/ssl/nomad-ca.pem -ca-key=nomad/ssl/nomad-ca-key.pem -profile=client \
    - | cfssljson -bare nomad/ssl/cli