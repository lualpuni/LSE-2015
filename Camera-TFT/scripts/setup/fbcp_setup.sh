#!/bin/bash

# Get location of script
shdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install -y cmake

# Build frame buffer copy program
git clone https://github.com/tasanakorn/rpi-fbcp.git /tmp/rpi-fbcp
cd /tmp/rpi-fbcp/
mkdir build
cd build
cmake ..
make
sudo cp ./fbcp /usr/local/bin

# Clean-up
cd $shdir
rm -rf /tmp/rpi-fbcp

# Set up System V init script to provide service
sudo cp ../service/fbcp_service.sh /etc/init.d/fbcp
sudo chmod 755 /etc/init.d/fbcp

exit 0
