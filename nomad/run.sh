#!/bin/bash

# Run Nomad server & cient in background
nomad agent -config config/server1.hcl &
nomad agent -config config/client1.hcl &
