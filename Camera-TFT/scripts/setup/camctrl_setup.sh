#!/bin/bash

# Get location of script
shdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Compile and check if finished successfully
cd $shdir/../../Camera-TFT/camctrl
python -O -m py_compile ./camctrl.py
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Install and make executable
sudo cp ./camctrl.pyo /usr/local/bin/
#sudo chmod 755 /usr/local/bin/camctrl.pyo

# Set up System V init script to provide service
sudo cp $shdir/../service/camctrl_service.sh /etc/init.d/camctrl
sudo chown root:root /etc/init.d/camctrl
sudo chmod 755 /etc/init.d/camctrl

exit 0
