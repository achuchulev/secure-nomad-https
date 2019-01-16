#!/usr/bin/env bash

echo "Starting Nomad...."

# Run Nomad server & agent in background
nomad agent -config ~/server1.hcl &> /dev/null &
nomad agent -config ~/client1.hcl &> /dev/null &
