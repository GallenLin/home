#!/bin/bash
function relpath_to_abspath() {
	if [ "$(echo $1|grep ^\/)" ];then
		echo "$1"
	elif [ "$(echo $1|grep ^\.)" ];then
		echo "$(pwd)/$(echo $1|sed -s "s/^\.\///g")"
	else
		echo "$(pwd)/$1"
	fi
}

workdir="$(pwd)"

tempfile="${workdir}/tmpfile"

function clean_temp() {
	rm -f ${tempfile}*
}


scandir="$(relpath_to_abspath $1)"
outdir="$(relpath_to_abspath $2)"



cd $scandir
find ./ -type l -printf "%l %p\n" > $tempfile
sed -i "s/\.//g" $tempfile

while read _item
do
	if [ "$(echo $_item|grep '^.*busybox')" ];then
		rel_file="$(echo $_item|sed -e "s/^.*busybox\ \///")"
		#echo "rel_file=$rel_file"
		rel_dir="$(dirname $rel_file)"
		wfile="$(basename $rel_file)"
		#echo "wfile=$outdir/$rel_dir/$wfile"
		mkdir -p "${outdir}/${rel_dir}"
		printf "#!/bin/busybox sh\n/bin/busybox $wfile \"\$@\"\n" > "${outdir}/${rel_dir}/${wfile}"
		chmod +x "${outdir}/${rel_dir}/${wfile}"
		#echo "---"
	fi
done < $tempfile

cd $workdir

clean_temp


