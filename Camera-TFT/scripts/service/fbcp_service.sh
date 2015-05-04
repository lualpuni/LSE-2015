#! /bin/sh
### BEGIN INIT INFO
# Provides:          fbcp
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:
# Default-Stop:      0 1 2 3 4 5 6
# Short-Description: Copy framebuffer.
# Description:       Copy /dev/FB0 (HDMI) to /dev/FB1 (TFT).
### END INIT INFO

#Required
USER=root

case "$1" in
  start)
        echo "Starting fbcp"
        start-stop-daemon --start --chuid $USER --name fbcp --pidfile /var/run/fbcp.pid \
         --background --make-pidfile --startas /usr/local/bin/fbcp -- --daemon
        ;;
  stop)
        echo "Stopping fbcp"
        start-stop-daemon --stop --chuid $USER --name fbcp --pidfile /var/run/fbcp.pid
        ;;

  restart|force-reload)
        echo "Stopping fbcp for Restart"
        start-stop-daemon --stop --chuid $USER --name fbcp --pidfile /var/run/fbcp.pid
        sleep 5s
        echo "Restarting fbcp"
        start-stop-daemon --start --chuid $USER --name fbcp --pidfile /var/run/fbcp.pid \
         --background --make-pidfile --startas /usr/local/bin/fbcp -- --daemon
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: fbcp {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac
exit 0
