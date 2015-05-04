#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <wiringPi.h>

#define portNo 2301

int main(int argc, char *argv[])
{
	int listen_fd, comm_fd;
	char cmd;

	struct sockaddr_in servaddr;

	listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (listen_fd == -1)
	{
		fprintf(stderr, "%s\n", strerror(errno));
		return 1;
	}

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family      = AF_INET;
	servaddr.sin_addr.s_addr = htons(INADDR_ANY);
	servaddr.sin_port        = htons(portNo);

	if (bind(listen_fd, (struct sockaddr *) &servaddr, sizeof(servaddr)) == -1)
	{
		fprintf(stderr, "%s\n", strerror(errno));
		return 1;
	}

	if (listen(listen_fd, 5) == -1)
	{
		fprintf(stderr, "%s\n", strerror(errno));
		return 1;
	}

	if (wiringPiSetupGpio() == -1)
	{
		fprintf(stderr, "Error: failed to set up WiringPi\n");
		return 1;
	}

	pinMode (18, PWM_OUTPUT);
	pinMode (13, PWM_OUTPUT);
	pwmSetMode(PWM_MODE_MS);
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
			fprintf(stderr, "%s\n", strerror(errno));
			return 1;
		}

		if (recv(comm_fd, &cmd, 1, 0) == -1)
		{
			fprintf(stderr, "%s\n", strerror(errno));
			return 1;
		}

		if (cmd & 0x80)
			pwmWrite(13, (100 + (((cmd & 0x7F) * 100) / 127)));
		else
			pwmWrite(18, (100 + (((cmd & 0x7F) * 100) / 127)));

		close(comm_fd);
	}
	close(comm_fd);
	close(listen_fd);
	return 0;
}
