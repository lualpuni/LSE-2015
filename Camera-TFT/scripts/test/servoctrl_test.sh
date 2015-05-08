#!/bin/bash

timeStep=0.0005
posStep=2

sudo /etc/init.d/servoctrl start
sleep 1

# Set both servos to minimum position
printf \\$(printf '%03o\t' 0)   | nc 127.0.0.1 2301
printf \\$(printf '%03o\t' 128) | nc 127.0.0.1 2301
sleep 1

# segment " _ "
for ((i=0; i<=127; i = i + $posStep)) do
   printf \\$(printf '%03o\t' "$i") | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment "  |"
for ((i=128; i<=255; i = i + $posStep)) do
   printf \\$(printf '%03o\t' "$i") | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment " ‾ "
for ((i=127; i>=0; i = i - $posStep)) do
   printf \\$(printf '%03o\t' "$i") | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment "|  "
for ((i=255; i>=128; i = i - $posStep)) do
   printf \\$(printf '%03o\t' "$i") | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment " / "
for ((i=0; i<=127; i = i + $posStep)) do
   printf \\$(printf '%03o\t' "$i")        | nc 127.0.0.1 2301
   printf \\$(printf '%03o\t' $((128+$i))) | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment " ‾ "
for ((i=127; i>=0; i = i - $posStep)) do
   printf \\$(printf '%03o\t' "$i") | nc 127.0.0.1 2301
   sleep $timeStep
done

# segment " \ "
for ((i=0; i<=127; i = i + $posStep)) do
   printf \\$(printf '%03o\t' "$i")        | nc 127.0.0.1 2301
   printf \\$(printf '%03o\t' $((255-$i))) | nc 127.0.0.1 2301
   sleep $timeStep
done

sudo /etc/init.d/servoctrl stop

echo "Have the servo motors completed the sequence successfully [Y/n]?"
read ans1
if ! [ $ans1 = "y" -o $ans1 = "Y" -o $ans1 = "yes" -o $ans1 = "YES" ]
then
	exit 1
fi

exit 0
