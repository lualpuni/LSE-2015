#!/usr/bin/env  python

import serial
import socket
import picamera
import time
import sys

if __name__ == '__main__':

    delta = 5
    pause = False
    xPos  = 64
    yPos  = 64

    # connect to serial port
    ser = serial.Serial()
    ser.port     = '/dev/ttyUSB0'
    ser.baudrate = 19200
    ser.bytesize = serial.EIGHTBITS
    ser.stopbits = serial.STOPBITS_ONE
    ser.parity   = serial.PARITY_NONE
    ser.rtscts   = False
    ser.xonxoff  = False
    ser.timeout  = None

    try:
        ser.open()
    except serial.SerialException, msg:
        print >> sys.stderr, "Could not open serial port:\n" + msg
        sys.exit(1)

    camera = picamera.PiCamera()
    camera.resolution = (640, 480)
    camera.start_preview()

    while True:
        cmd = ser.read(1)

        d = ((ord(cmd[0]) & (1 << 0)) >> 0)
        u = ((ord(cmd[0]) & (1 << 1)) >> 1)
        r = ((ord(cmd[0]) & (1 << 2)) >> 2)
        l = ((ord(cmd[0]) & (1 << 3)) >> 3)

        if (((d == 0) and (u == 0)) or ((l == 0) and (r == 0))):
            if (pause == False):
                camera.capture('/home/pi/capture.jpg')
                camera.stop_preview()
                pause = True
            else:
                camera.start_preview()
                pause = False
        else:
            if (d == 0): xPos = (xPos - delta) if ((xPos - delta) > 0)   else 0
            if (u == 0): xPos = (xPos + delta) if ((xPos + delta) < 127) else 127
            if (r == 0): yPos = (yPos - delta) if ((yPos - delta) > 0)   else 0
            if (l == 0): yPos = (yPos + delta) if ((yPos + delta) < 127) else 127

            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                s.connect(('', 2301))
            except socket.error, (val, msg):
                print >> sys.stderr, "Could not open socket:\n" + msg
                sys.exit(1)
            s.send(chr(xPos + 0))
            s.shutdown(socket.SHUT_RDWR)
            s.close()

            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                s.connect(('', 2301))
            except socket.error, (val, msg):
                print >> sys.stderr, "Could not open socket:\n" + msg
                sys.exit(1)
            s.send(chr(yPos + 128))
            s.shutdown(socket.SHUT_RDWR)
            s.close()
