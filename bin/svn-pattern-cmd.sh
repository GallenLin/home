#!/bin/bash

function usage() {
	cat >&2 <<- EOF

	This tool help you run "svn rm" for each pattern you assigned .

	Usage: ${0} [-t] [-c] [-C <svn command>] [pattern]
	
	pattern: the pattern which you want to remove in this svn working folder .

	Options:
	 -t run as test mode : it's just show what will do .
	 -c do not run svn st ,get status from file \".svn-status.txt\" .
	 -C svn command :eg, "rm" , "add" , "ci" , "revert" .

	example:
	 remove all "M     *.cmd" files which shown in svn st : 
	  ${0} -C rm ^[M].*\.cmd 
	 remove all "M     *.cmd" or "!    *.cmd" files which shown in svn st : 
	  ${0} -C rm ^[M!].*\.cmd 
	 add all "?     *.c" files which shown in svn st : 
	  ${0} -C add ^[?].*\.c 
	 revert all "!     *.jpg" files which shown in svn st : 
	  ${0} -C revert ^[!].*\.jpg 
	 commit all "M     *.c" files which shown in svn st : 
	  ${0} -C ci ^[M].*\.c 

	EOF
}


testmode="0"
patchrun="0"
forcesvnst="1"
SVNCMD="rm"
while getopts "C:tc" opt
do
	case ${opt} in
		c ) 
			forcesvnst="" ;;
		t ) 
			testmode="1" ;;
		p ) 
			patchrun="1" ;;
		C ) 
			SVNCMD="${OPTARG}" ;;
		\? ) 
			usage 
			exit 0 ;;
	esac
done
shift "$(expr ${OPTIND} - 1)"



function docmd() {
	if [ $testmode = "1" ];then
		echo $@
	else
		$@
	fi
}


if [ "$1" ];then
	RMPATTERN="$1"
else
	usage
	exit 1	
fi


SVNSTFILE=".svn-status.txt"

if [ -f $SVNSTFILE ] && [ -z $forcesvnst ] ;then
	echo -n ""
else
	svn st > $SVNSTFILE
fi


DOTCMDLIST=$(cat $SVNSTFILE |grep $RMPATTERN|sed -e "s/^.\ *//g"|sed -e "s/^+\ *//g")
SVNRMFLAG=""
askforce=0

if [ "$SVNCMD" = "ci" ];then
	docmd svn ci $DOTCMDLIST 
elif [ "$SVNCMD" = "mv" ];then
	echo "not support command \"mv\" !"
else
	for DOTCMDITEM in $DOTCMDLIST
	do
		echo "svn $SVNCMD $SVNRMFLAG $DOTCMDITEM"
		docmd svn $SVNCMD $SVNRMFLAG $DOTCMDITEM
		if [ $? != 0 ];then
			if [ $askforce = 0 ];then
				echo -n "svn $SVNCMD fail !whould you like to add \"--force\" into \"svn $SVNCMD\" command ? [Y/N] "
				read yesno
				if [ "$yesno" = "Y" ] || [ "$yesno" = "y" ]; then
					echo "add --force to svn $SVNCMD "
					SVNRMFLAG="--force "
					docmd svn $SVNCMD $SVNRMFLAG $DOTCMDITEM
				fi
				askforce=1
			fi
		fi
	done
fi


