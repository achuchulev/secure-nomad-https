#!/bin/bash

# Run Nomad server & cient in background
nomad agent -config /vagrant/config/server1.hcl &
nomad agent -config /vagrant/config/client1.hcl &
