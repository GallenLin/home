#!/bin/bash

gconftool-2 --type bool --set /apps/nautilus/preferences/media_automount false
gconftool-2 --get /apps/nautilus/preferences/media_automount
logout

