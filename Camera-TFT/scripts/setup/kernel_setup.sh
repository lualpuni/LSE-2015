#!/bin/bash

# Function taken from raspi-config script
function set_config_var() {
  lua - "$1" "$2" "$3" <<EOF > "$3.bak"
local key=assert(arg[1])
local value=assert(arg[2])
local fn=assert(arg[3])
local file=assert(io.open(fn))
local made_change=false
for line in file:lines() do
  if line:match("^#?%s*"..key.."=.*$") then
    line=key.."="..value
    made_change=true
  end
  print(line)
end

if not made_change then
  print(key.."="..value)
end
EOF
mv "$3.bak" "$3"
}

# Backup kernel
sudo cp /boot/kernel.img /boot/kernel.img.bak.raspbian

# Add apt.adafruit.com to list of software sources
curl -SLs https://apt.adafruit.com/add | sudo bash

# Update system and install kernel
sudo apt-get update; sudo apt-get upgrade -y
sudo apt-get install -y adafruit-pitft-helper

# Back-up boot configuration and create copy
sudo cp /boot/config.txt /boot/config.txt.raspbian.bak
cat /boot/config.txt > /tmp/config.txt

# Add the device tree overlay manually
#echo "" >> /tmp/config.txt
#echo "[pi1]" >> /tmp/config.txt
#echo "device_tree=bcm2708-rpi-b-plus.dtb" >> /tmp/config.txt
#echo "[pi2]" >> /tmp/config.txt
#echo "device_tree=bcm2709-rpi-2-b.dtb" >> /tmp/config.txt
#echo "[all]" >> /tmp/config.txt
#echo "dtparam=spi=on" >> /tmp/config.txt
#echo "dtparam=i2c1=on" >> /tmp/config.txt
#echo "dtparam=i2c_arm=on" >> /tmp/config.txt
#echo "dtoverlay=pitft28r,rotate=90,speed=32000000,fps=20" >> /tmp/config.txt

# Enable camera
set_config_var start_x 1 /tmp/config.txt
set_config_var gpu_mem 128 /tmp/config.txt
sed /tmp/config.txt -i -e "s/^startx/#startx/"
sed /tmp/config.txt -i -e "s/^fixup_file/#fixup_file/"

# Write-back boot configuration
sudo chown root:root /tmp/config.txt
sudo chmod 766 /tmp/config.txt
sudo mv /tmp/config.txt /boot

# Deactivate accelerated X framebuffer
if [[ ! -e ~/.backup ]]; then mkdir ~/.backuph; fi
sudo mv /usr/share/X11/xorg.conf.d/99-fbturbo.conf ~/.backup

# Simple install script [edit]
sudo adafruit-pitft-helper -t 28r

# User message
echo "Reboot required..." >&2

exit 0
