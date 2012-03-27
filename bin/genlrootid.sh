#!/bin/bash


function usage() {
	cat >&2 <<- EOF

	This tool help you to scan linux root folder write the layout save into one file .

	Usage: ${0} [-t] [-s <pathname>] [-o <pathname>] 

	savetofolder : Please give a full path folder ,If it's not exist this tool will create .

	Options:
	-o <pathname> : output pathname .
	-s <pathname> : source pathname .
	-t : run as test mode : it's just show what will do .


	EOF
}

OutputPath="/tmp/tree-out.txt"
SourcePath="./"
forceflag=""
testmode="0"

while getopts "s:o:t" opt
do
	case ${opt} in
		t ) 
			testmode="1" ;;
		o ) 
			OutputPath="${OPTARG}" ;;
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




workdir=$(pwd)

cd "$SourcePath"
if [ "$?" = "0" ];then
	docmd sudo tree -o ${OutputPath}
	docmd sudo tree -p -s -n -o ${OutputPath}-detail
	docmd sudo tree -p -s -C -H localpath -T ROOT-SCAN -o ${OutputPath}-detail.html
else 
	echo "cd $SourcePath fail !!!"
fi
cd $workdir


