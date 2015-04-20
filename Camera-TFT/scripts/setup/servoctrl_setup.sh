#!/bin/bash

# Get location of script
shdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install -y git-core

# Install wiringPi
git clone git://git.drogon.net/wiringPi /tmp/rpi-wiringpi
cd /tmp/rpi-wiringpi
git pull origin

# Build/install and check if finished successfully
./build
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Clean-up
cd ~/
rm -rf /tmp/rpi-wiringpi

#   [...not finished...]

# Set up System V init script to provide service
sudo cp $shdir/../service/servoctrl_service.sh /etc/init.d/servoctrl
sudo chmod 755 /etc/init.d/servoctrl

exit 0
