#!/bin/bash

# Help function
function help_func()
{
    echo "Usage: client.sh IP_ADDR ARG"
    echo ""
	  echo "Arguments:"
    echo "    vlc   - Use VideoLAN [portable]."
    echo "    nc    - Use Netcat   [low latency]."
    echo "    help  - Show this message."
    echo ""
}

# Parse command line options.
case "$2" in
    vlc)
        vlc http://$1:1234 2&> /dev/null
        exit 0
        ;;

    nc)
        mplayer -fps 200 -demuxer h264es ffmpeg://tcp://$1:1234 2&> /dev/null
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
