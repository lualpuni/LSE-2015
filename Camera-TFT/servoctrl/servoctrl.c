#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <wiringPi.h>
#include <softPwm.h>

#define portNo 2301
#define servo0 21
#define servo1 21
 
int main(int argc, char *argv[])
{
    int listen_fd, comm_fd;
    char cmd;
 
    struct sockaddr_in servaddr;

	if (wiringPiSetup() == -1)
	{
		fprintf(stderr, "Error: failed to set up WiringPi\n");
		return 1;
	}

	pinMode(servo0, OUTPUT);
	pinMode(servo1, OUTPUT);

	softPwmCreate(servo0, 0, 200);
	softPwmCreate(servo1, 0, 200);

	softPwmWrite(servo0, 15);
	softPwmWrite(servo1, 15);
 
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
 
    if (listen(listen_fd, 1) == -1)
    {
        fprintf(stderr, "%s\n", strerror(errno));
        return 1;
    }

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
		
		if (cmd & (1 << 8))
		{
			softPwmWrite(servo1, (10 + (((cmd & 0x7F) * 10)/127)));
		}
		else
		{
			softPwmWrite(servo0, (10 + (((cmd & 0x7F) * 10)/127)));
		}

		close(comm_fd);
    }
	close(listen_fd);
	return 0;
}

