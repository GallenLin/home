#!/usr/bin/python3

from gpiozero import Button
import time
from signal import pause
from datetime import datetime

stat_chg_cnt = 0

last_time=time.clock_gettime(time.CLOCK_BOOTTIME)
timeout_secs = 1

def sw_handle() :
	global stat_chg_cnt
	global sw
	global sw_stat_before_chg

	if stat_chg_cnt==0:
	    sw_stat_before_chg = sw.value
	cur_time=time.clock_gettime(time.CLOCK_BOOTTIME)
	stat_chg_cnt+=1
	last_time = cur_time

def sw_on_handle() :
	#print("sw on")
	sw_handle()

def sw_off_handle() :
	#print("sw off")
	sw_handle()

sw=Button(21,pull_up=False)
sw.when_pressed = sw_on_handle
sw.when_released = sw_off_handle
sw_stat_before_chg = sw.value;

while 1 : 
	time.sleep(1)
	if stat_chg_cnt > 0 :
		cur_time=time.clock_gettime(time.CLOCK_BOOTTIME)
		diff_time = cur_time - last_time
		if diff_time > timeout_secs :
			now = datetime.now()
			print(now,"switch changed cnt=",stat_chg_cnt,",",sw_stat_before_chg,"->",sw.value)
			stat_chg_cnt = 0
	
#time.sleep(1)
pause()


