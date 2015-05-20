#! /bin/sh
### BEGIN INIT INFO
# Provides:          camctrl
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:
# Default-Stop:      0 1 2 3 4 5 6
# Short-Description: Control camera.
# Description:       Control camera and pan/tilt with commands over UART.
### END INIT INFO

#!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!! CURRENTLY NOT WORKING !!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!

#Required
USER=pi

case "$1" in
  start)
        echo "Starting camctrl"
        start-stop-daemon --start --chuid $USER --name camctrl --pidfile /var/run/camctrl.pid \
         --background --make-pidfile --startas /usr/local/bin/camctrl.py -- --daemon
        ;;
  stop)
        echo "Stopping camctrl"
        start-stop-daemon --stop --chuid $USER --name camctrl --pidfile /var/run/camctrl.pid
        ;;

  restart|force-reload)
        echo "Stopping camctrl for Restart"
        start-stop-daemon --stop --chuid $USER --name camctrl --pidfile /var/run/camctrl.pid
        sleep 5s
        echo "Restarting camctrl"
        start-stop-daemon --start --chuid $USER --name camctrl --pidfile /var/run/camctrl.pid \
         --background --make-pidfile --startas /usr/local/bin/camctrl.py -- --daemon
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: camctrl {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac
exit 0
