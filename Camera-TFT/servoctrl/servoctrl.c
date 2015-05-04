#include <errno.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <wiringPi.h>

#define portNo 2301

static volatile int listen_fd, comm_fd;

static void signalHandler(int signum)
{
	close(comm_fd);
	close(listen_fd);
	syslog(LOG_INFO, "stopping\n");
	closelog();
	exit (0);
}

int main(int argc, char *argv[])
{
	char cmd;

	struct sockaddr_in servaddr;
	struct sigaction action;

	memset(&action, 0, sizeof(struct sigaction));
	action.sa_handler = signalHandler;

	if (sigaction(SIGINT,  &action, NULL) == -1)
	{
		syslog(LOG_ERR, "%s\n", strerror(errno));
		return 1;
	}

	if (sigaction(SIGTERM, &action, NULL) == -1)
	{
		syslog(LOG_ERR, "%s\n", strerror(errno));
		return 1;
	}

	openlog("servoctrl", LOG_PID, LOG_DAEMON);
	syslog(LOG_INFO, "starting\n");

	listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (listen_fd == -1)
	{
		syslog(LOG_ERR, "%s\n", strerror(errno));
		return 1;
	}

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family      = AF_INET;
	servaddr.sin_addr.s_addr = htons(INADDR_ANY);
	servaddr.sin_port        = htons(portNo);

	if (bind(listen_fd, (struct sockaddr *) &servaddr, sizeof(servaddr)) == -1)
	{
		syslog(LOG_ERR, "%s\n", strerror(errno));
		return 1;
	}

	if (listen(listen_fd, 5) == -1)
	{
		syslog(LOG_ERR, "%s\n", strerror(errno));
		return 1;
	}

	if (wiringPiSetupGpio() == -1)
	{
		syslog(LOG_ERR, "failed to set up WiringPi\n");
		return 1;
	}

	pinMode (18, PWM_OUTPUT);
	pinMode (13, PWM_OUTPUT);
	pwmSetMode(PWM_MODE_MS);
	pwmSetClock(192);
	pwmSetRange(2000);
	pwmWrite(18, 150);
	pwmWrite(13, 150);

	while(1)
	{
		comm_fd = accept(listen_fd, (struct sockaddr*) NULL, NULL);
		if (comm_fd == -1)
		{
			syslog(LOG_ERR, "%s\n", strerror(errno));
			return 1;
		}

		if (recv(comm_fd, &cmd, 1, 0) == -1)
		{
			syslog(LOG_ERR, "%s\n", strerror(errno));
			return 1;
		}

		if (cmd & 0x80)
			pwmWrite(13, (100 + (((cmd & 0x7F) * 100) / 127)));
		else
			pwmWrite(18, (100 + (((cmd & 0x7F) * 100) / 127)));

		close(comm_fd);
	}
	return 0;
}
