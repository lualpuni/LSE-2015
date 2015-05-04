#! /bin/sh
### BEGIN INIT INFO
# Provides:          servoctrl
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:
# Default-Stop:      0 1 2 3 4 5 6
# Short-Description: Servo control.
# Description:       Control up to 2 servos with hardware PWM.
### END INIT INFO

#Required
USER=pi              #Set username here.

case "$1" in
  start)
        echo "Starting servoctrl"
        start-stop-daemon --start --chuid $USER --name servoctrl --pidfile /var/run/servoctrl.pid \
         --background --make-pidfile --exec /usr/local/bin/servoctrl -- --do-not-daemonize 
        ;;
  stop)
        echo "Stopping servoctrl"
        start-stop-daemon --stop --chuid $USER --name servoctrl --pidfile /var/run/servoctrl.pid
        ;;

  restart|force-reload)
        echo "Stopping servoctrl for Restart"
        start-stop-daemon --stop --chuid $USER --name servoctrl --pidfile /var/run/servoctrl.pid
        sleep 5s
        echo "Restarting servoctrl"
        start-stop-daemon --start --chuid $USER --name servoctrl --pidfile /var/run/servoctrl.pid \
         --background --make-pidfile --exec /usr/local/bin/servoctrl -- --do-not-daemonize 
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: servoctrl {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac
exit 0
