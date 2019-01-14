#!/bin/bash

# Run Nomad server & cient in background
nomad agent -config /vagrant/config/server1.hcl > /dev/null 2>&1
#nomad agent -config /vagrant/config/client1.hcl > /dev/null 2>&1
