CC      = gcc
CFLAGS  = -g -Wall -Werror -lwiringPi -O3
OBJECTS = servoctrl.o

servoctrl : $(OBJECTS)
	$(CC) $(PFLAGS) $(CFLAGS) $(OBJECTS) -o servoctrl

%.o : %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f *.o servoctrl
