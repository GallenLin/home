#!/bin/bash
. rmediafunc.sh
rdev=$(get_last_removeable_media)
if [ "${rdev}" = "" ];then
	echo "removeable media not exist !!"
	exit 1
fi

echo -n "to umount last removeable media \"$rdev\"..."
umount_removeable_media $rdev
echo " [done]"

