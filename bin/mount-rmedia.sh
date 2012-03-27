#!/bin/bash
. rmediafunc.sh
rdev=$(get_last_removeable_media)
if [ "${rdev}" = "" ];then
	echo "removeable media not exist !!"
	exit 1
fi

echo -n "to mount last removeable media \"${rdev}\" ..."
mntpt=$(mount_removeable_media "${rdev}")
for m in ${mntpt}
do
	sudo chmod 777 $m
done
echo -n "${mntpt}"
echo " [done]"

exit 0
