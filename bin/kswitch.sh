#!/bin/bash
function usage() {
	cat <<- EOF
	$0 <linux-kernel-srcdir>
	where : 
		<linux-kernel-srcdir> : linux kernel source that you want to switch to .
	example : 
		in folder "rpm/BUILD" :
		$0 linux-2.6.28-test 
			link linux-2.6.28 from linux-2.6.28-test

	EOF
}

ORG_KERNEL="linux-2.6.28"

if [ "$1" ];then
	rm "$ORG_KERNEL"
	if [ $? = 0 ];then
		ln -s "$1" "$ORG_KERNEL"
		echo "relink \"$ORG_KERNEL\" from \"$1\""
	else
		echo "remove link \"$ORG_KERNEL\"fail !"
	fi
else
	usage
fi

