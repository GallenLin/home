#!/usr/bin/python3

from gpiozero import LED
import time
from signal import pause

io=LED(20)

for x in range(6):
	io.on()
	time.sleep(0.000001)
	io.off()
	time.sleep(0.000001)

time.sleep(1)
#pause()


