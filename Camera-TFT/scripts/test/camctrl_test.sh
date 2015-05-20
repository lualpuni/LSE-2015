#!/bin/bash

# Get location of script
shdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sudo /etc/init.d/fbcp start
sudo /etc/init.d/servoctrl start
screen -d -m -S camctrl python /usr/local/bin/camctrl.py

echo "Is the TFT LCD touchscreen relaying the camera image [Y/n]?"
read ans1
if ! [ $ans1 = "y" -o $ans1 = "Y" -o $ans1 = "yes" -o $ans1 = "YES" ]
then
	exit 1
fi

# Send "pause" command
python $shdir/camctrl-dummy.py 0 0 0 0

echo "Has the TFT LCD touchscreen stopped relaying the camera image [Y/n]?"
read ans2
if ! [ $ans2 = "y" -o $ans2 = "Y" -o $ans2 = "yes" -o $ans2 = "YES" ]
then
	exit 1
fi

# Send "resume" command
python $shdir/camctrl-dummy.py 0 0 0 0

# move in a square path
for i in `seq 1 5`;  do python $shdir/camctrl-dummy.py 0 1 1 1; done
for i in `seq 1 5`;  do python $shdir/camctrl-dummy.py 1 1 0 1; done
for i in `seq 1 10`; do python $shdir/camctrl-dummy.py 1 0 1 1; done
for i in `seq 1 10`; do python $shdir/camctrl-dummy.py 1 1 1 0; done
for i in `seq 1 10`; do python $shdir/camctrl-dummy.py 0 1 1 1; done
for i in `seq 1 5`;  do python $shdir/camctrl-dummy.py 1 1 0 1; done
for i in `seq 1 5`;  do python $shdir/camctrl-dummy.py 1 0 1 1; done

echo "Did the mechanism follow a square path [Y/n]?"
read ans3
if ! [ $ans3 = "y" -o $ans3 = "Y" -o $ans3 = "yes" -o $ans3 = "YES" ]
then
	exit 1
fi
