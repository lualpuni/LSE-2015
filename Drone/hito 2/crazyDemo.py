#!/usr/bin/python
import time
import sys
import tty
import termios
import argparse
import cflib
from cflib.crazyflie import Crazyflie
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from threading import Thread, Event
from datetime import datetime
accelvaluesX = []
accelvaluesY = []
accelvaluesZ = []
#import Gnuplot

class TestFlight:

    roll = 0 	
    pitch = 0	
    yawrate = 0	
    thrust = 0

    hold = "False"

    trimmed_roll = 0
    trimmed_pitch = 0

    def __init__(self):
        """
        Initialize the quadcopter
        """
        self.f = open('log.log', 'w')

        self.starttime = time.time()*1000.0

        self.crazyflie = cflib.crazyflie.Crazyflie()
        print 'Initializing drivers' 
        cflib.crtp.init_drivers()
 
        print 'Searching for available devices'
        available = cflib.crtp.scan_interfaces()

        radio = False
        for i in available:
            # Connect to the first device of the type 'radio'
            if 'radio' in i[0]:
                radio = True
                dev = i[0]
                print 'Connecting to interface with URI [{0}] and name {1}'.format(i[0], i[1])
                self.crazyflie.open_link(dev)
                break

        if not radio:
            print 'No quadcopter detected. Try to connect again.'
            exit(-1)

        # Set up the callback when connected
        self.crazyflie.connected.add_callback(self.connectSetupFinished)


    def connectSetupFinished(self, linkURI):
        """
        Set the loggers
        """
        # Log stabilizer
        self.logStab = LogConfig("Stabalizer", 200)
        self.logStab.add_variable("stabilizer.roll", "float")
        self.logStab.add_variable("stabilizer.pitch", "float")
        self.logStab.add_variable("stabilizer.yaw", "float")
        self.logStab.add_variable("stabilizer.thrust", "uint16_t")
 
        self.crazyflie.log.add_config(self.logStab)
 
        if self.logStab.valid:
            self.logStab.data_received_cb.add_callback(self.print_stab_data)
            self.logStab.start()
        else:
            print 'Could not setup log configuration for stabilizer after connection!'


        Thread(target=self.increasing_step).start() 
        Thread(target=self.pulse_command).start()

    def print_stab_data(self, ident, data, logconfig):
        #sys.stdout.write('Stabilizer: Roll={1:.2f}, Pitch={2:.2f}\r'.format(data["stabilizer.roll"], data["stabilizer.pitch"]))
        #sys.stdout.flush()

        trim_roll = (-1)*data["stabilizer.roll"] + 3.2
        trim_pitch = (-1)*data["stabilizer.pitch"] -0.2

        if trim_roll != 0 or trim_pitch != 0:    
            self.trimmed_roll = self.roll + trim_roll
            self.trimmed_pitch = self.pitch + trim_pitch

    def increasing_step(self):
        while 1:
            command = raw_input("Set thrust (0-100)% (0 will turn off the motors, e:")

            if (command=="e"):
				# Exit the main loop
                self.hold = "False"
                print "Exiting main loop in 1 second"
                time.sleep(0.5)
                self.crazyflie.close_link() # This errors out for some reason. Bad libusb?

            elif (command=="h"):
                if self.hold == "True":
                    self.hold = "False"
                    self.thrust = 42500
                    print "You're NOT in Hover Mode" 
                else:
                    self.hold = "True"
                    self.thrust = 32767
                    print "You're in Hover Mode" 


            elif (self.is_number(command)):
				# Good thrust value
				self.thrust_a = (int(command))

				if self.thrust_a <=100:
				    if int(command) == 0:
				        self.hold = "False"
				    self.thrust = (int(command)*555 + 10000)
				    print "Setting thrust to %i" % (int(command))

				else:
				    print "Remember. Enter a number (0 - 100) or e to exit"

    def pulse_command(self):

        while 1:
            self.crazyflie.param.set_value('flightmode.althold', self.hold)
                
            self.crazyflie.commander.send_setpoint(self.trimmed_roll, self.trimmed_pitch, self.yawrate, self.thrust)
            time.sleep(0.1)       
	 

    def is_number(self, s):
        try:
            int(s)
            return True
        except ValueError:
            return False

TestFlight()
