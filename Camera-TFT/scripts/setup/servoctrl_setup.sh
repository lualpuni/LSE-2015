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
./build
cd $shdir
rm -rf /tmp/rpi-wiringpi


