#!/bin/bash

screen -d -m -S raspivid raspivid -t 0 -w 640 -h 480 -fps 20

sudo /etc/init.d/fbcp start
echo "Is the TFT LCD touchscreen relaying the camera image [Y/n]?"
read ans1
if ! [ $ans1 = "y" -o $ans1 = "Y" -o $ans1 = "yes" -o $ans1 = "YES" ]
then
	exit 1
fi

sudo /etc/init.d/fbcp stop
echo "Has the TFT LCD touchscreen stopped relaying the camera image [Y/n]?"
read ans2
if ! [ $ans2 = "y" -o $ans2 = "Y" -o $ans2 = "yes" -o $ans2 = "YES" ]
then
	exit 1
fi

# Cleanup
screen -S raspivid -X quit
sudo sh -c "TERM=linux setterm -foreground black -clear >/dev/tty0"
sudo /etc/init.d/fbcp start
sleep 1
sudo /etc/init.d/fbcp stop
sudo sh -c "TERM=linux setterm -foreground white -clear >/dev/tty0"

exit 0
