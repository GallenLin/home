#!/bin/bash


function usage() {
	cat >&2 <<- EOF

	This tool save ".svn" folder into another folder which you give in arguments .

	Usage: ${0} [-v] [-m] [-t] [-A <Y|N|A>] [-s <pathname>] [-b <pathname>] <savetofolder>
	
	savetofolder : Please give a full path folder ,If it's not exist this tool will create .

	Options:
	-v : show more infomation in processing .
	-m : move mode (original ".svn" will be removed).
	-f : force overwrite ".svn"
	-A <Answer Y/N/A> : answer of any question .
	-b <pathname> : backup ".svn" into single file with tarball gzip format will be saved as pathname .
	-s <pathname> : source ".svn" path ,If not set default is current folder .
	-t : run as test mode : it's just show what will do .


	EOF
}

showinfo="0"
movemode="0"
BackupPath=""
SourcePath="./"
forceflag=""
testmode="0"
AutoAnswer=""
while getopts "A:s:b:vmft" opt
do
	case ${opt} in
		v ) 
			showinfo="1" ;;
		m ) 
			movemode="1" ;;
		f ) 
			forceflag="f" ;;
		t ) 
			testmode="1" ;;
		A ) 
			AutoAnswer="${OPTARG}" ;;
		b ) 
			BackupPath="${OPTARG}" ;;
		s )
			SourcePath="${OPTARG}" ;;
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
	savetodir="$1"
else
	usage
	exit 0
fi

if [ -d "$savetodir" ];then
	echo -n "$savetodir already exist !! remove it ? [(Y)es/(N)o/(A)bort] : " 
	if [ "$AutoAnswer" ];then
		ans="$AutoAnswer"
		echo "Auto answer : $ans"
	else
	read ans
 	fi	
	echo ""

	if [ "$ans" = "y" ] || [ "$ans" = "Y" ] ;then
		[ "$showinfo" = "1" ] && echo -n "remove $savetodir ..."
		docmd rm -fr "$savetodir"
		[ "$showinfo" = "1" ] && echo "done"
		docmd mkdir -p $savetodir
	elif [ "$ans" = "n" ] || [ "$ans" = "N" ];then
		echo ""
	elif [ "$ans" = "a" ] || [ "$ans" = "A" ] || [ "$ans" = "" ];then
		echo "abort by user !"
		exit 0	
	fi
else
	mkdir -p $savetodir
fi


workdir=$(pwd)

cd "$SourcePath"
svnfolderlist=$(find . -name .svn)

if [ "$movemode" = "1" ];then
	savecmd="mv"
	savecmdopt="-${forceflag}"
else
	savecmd="cp"
	savecmdopt="-a${forceflag}"
fi

for svnfld in $svnfolderlist
do
	if [ -d $svnfld ];then
		[ "$showinfo" = "1" ] && echo -n "$savecmd "$workdir"/"$svnfld" to "$savetodir"/"$svnfld" ..."
		
		tocreatedir="$(dirname "$savetodir"/"$svnfld")"
		if [ -d "$tocreatedir" ];then
			echo -n ""
			#echo ""
		else
			#echo -n "create $tocreatedir ..."
			#echo ""
			mkdir -p "$tocreatedir"
		fi

		docmd $savecmd $savecmdopt "$workdir"/"$svnfld" "$savetodir"/"$svnfld"

		if [ $? != 0 ];then
			echo "prcess fail !!"
			exit -1
		fi

		[ "$showinfo" = "1" ] && echo "[done]"
	fi
done

if [ "$BackupPath" ];then
	cd "$savetodir"
	[ $? = 0 ] && docmd tar zcf "$BackupPath" ./
	if [ $? = 0 ];then
		[ "$showinfo" = "1" ] && echo "backup .svn info into $BackupPath success !"
	else 
		echo "backup .svn info into $BackupPath fail !"
	fi
	cd "$workdir"
fi

