#!/bin/bash
. ~/bin/mount_helper.sh

mount_cifs 192.80.1.100 d $HOME/home_share
mount_cifs 192.80.1.100 tools $HOME/home_tools


