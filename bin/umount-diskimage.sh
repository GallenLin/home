#!/bin/bash
. rmediafunc.sh

image_file="$1"
echo -n "to umount disk image \"$image_file\"..."
umount_disk_image "$image_file"
echo " [done]"

