#!/usr/bin/python3

from gpiozero import LED
from gpiozero import Button
import time
from signal import pause

def sw_on_handle():
	print("switch on")

def sw_off_handle():
	print("switch off")

sw=Button(21,pull_up=False)
sw.when_pressed = sw_on_handle
sw.when_released = sw_off_handle
io=LED(20)

io.on()
time.sleep(0.000001)
io.off()
#time.sleep(1)
pause()


