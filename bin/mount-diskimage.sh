#!/bin/bash
. rmediafunc.sh

image_file="$1"
echo -n "to mount disk image \"$image_file\" ..."
mount_disk_image "$image_file"
echo " [done]"

exit 0
