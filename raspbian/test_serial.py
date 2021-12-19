#!/usr/bin/python3

import serial
import getopt,sys
from datetime import datetime
import threading


def tty_input_work():
	global tty
	for in_line in sys.stdin:
		print("->",tty.name,in_line)
		tty.write(in_line.encode())


ttydev=sys.argv[1]
ttybaudrate=sys.argv[2]
print("tty device =",ttydev,"baudrate=",ttybaudrate)

tty=serial.Serial(ttydev,ttybaudrate)

tty_input = threading.Thread(target = tty_input_work)
tty_input.start()

try :
	while True :
		while tty.in_waiting:
			data_raw = tty.readline()
			data = data_raw.decode()
			print(datetime.now(),data,end='')

except KeyboardInterrupt :
	tty.close()
	print("Bye!!")

print("-end-")
tty_input.join()


