#!/bin/bash

# Help function
function help_func()
{
    echo "Usage: demo.sh ARG"
    echo ""
	  echo "Arguments:"
    echo "    vlc   - Use VideoLAN [portable]."
    echo "    nc    - Use Netcat   [low latency]."
    echo "    help  - Show this message."
    echo ""
}

# Cleanup function
function cleanup {
  screen -S fbcp -X quit
  sudo sh -c "TERM=linux setterm -foreground white -clear >/dev/tty0"
  exit 0
}
trap cleanup SIGINT SIGTERM

# Start fbco in detached mode
screen -d -m -S fbcp /usr/local/bin/fbcp

# Make terminal blank
sudo sh -c "TERM=linux setterm -foreground black -clear >/dev/tty0"

# Parse command line options.
case "$1" in
    vlc)
        raspivid -t 0 -w 640 -h 480 -fps 20 -o - | cvlc --noaudio\
        --no-sout-audio -v stream:///dev/stdin --sout\
        '#standard{access=http,mux=ts,dst=:1234}' :demux=h264 2&> /dev/null
        exit 0
        ;;

    nc)
        raspivid -t 0 -w 640 -h 480 -fps 20 -o -| nc -k -l 1234
        exit 0
        ;;

    help)
        help_func
        exit 0
        ;;

    *)
        echo "Invalid or missing argument" >&2
        help_func
        exit 1
		;;
esac
