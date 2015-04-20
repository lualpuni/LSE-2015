#! /bin/sh
### BEGIN INIT INFO
# Provides:          servocrtl
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:
# Default-Stop:      0 1 2 3 4 5 6
# Short-Description: Servo motor controller.
# Description:       Control up to 2 servo motors with GPIOs.
### END INIT INFO

#Required
USER=pi              #Set username here.

case "$1" in
  start)
        echo "Starting servocrtl"
        start-stop-daemon --start --chuid $USER --name servocrtl --pidfile /var/run/servocrtl.pid \
         --background --make-pidfile --exec /usr/local/bin/servocrtl -- --do-not-daemonize 
        ;;
  stop)
        echo "Stopping servocrtl"
        start-stop-daemon --stop --chuid $USER --name servocrtl --pidfile /var/run/servocrtl.pid
        ;;

  restart|force-reload)
        echo "Stopping servocrtl for Restart"
        start-stop-daemon --stop --chuid $USER --name servocrtl --pidfile /var/run/servocrtl.pid
        sleep 5s
        echo "Restarting servocrtl"
        start-stop-daemon --start --chuid $USER --name servocrtl --pidfile /var/run/servocrtl.pid \
         --background --make-pidfile --exec /usr/local/bin/servocrtl -- --do-not-daemonize 
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: servocrtl {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac
exit 0
