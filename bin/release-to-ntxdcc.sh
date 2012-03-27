#!/bin/bash
function _GetURL_Revision() {
	URL="${1}"
	_TMP="$(LANG=en svn info "${URL}"|grep "Revision:")"
	REVISION="$(echo "${_TMP}"|sed -e "s/Revision: //" 2>/dev/null)"
	echo ${REVISION}
}


SVNBASEURL=" https://gallen-desktop:8443/svn"
WORKDIR="$(pwd)"

DATE="$(date +%Y%m%d)"


# T1
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/mp/t1"
svn export ${FULLURL} t1
REV=$(_GetURL_Revision ${FULLURL})
tar zcvf t1-${DATE}-r${REV}.tgz t1
rm -fr t1

# T1.3
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/mp/t1.3/sdcard"
svn export ${FULLURL} t1.3
REV=$(_GetURL_Revision ${FULLURL})
tar zcvf t1.3-${DATE}-r${REV}.tgz t1.3
rm -fr t1.3

# T2
mkdir t2
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/ltib/user/show"
svn export ${FULLURL} t2/show
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/mp/t2/sdcard"
svn export ${FULLURL} t2/sdcard
REV=$(_GetURL_Revision ${FULLURL})
tar zcvf t2-${DATE}-r${REV}.tgz t2
rm -fr t2

# T3
mkdir t3
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/mp/t3/sdcard"
svn export ${FULLURL} t3/sdcard
FULLURL="${SVNBASEURL}/netronix/trunk/mx35/E60810/ltib/user/microwin_starestk"
svn export ${FULLURL} t3/microwin_starestk
REV=$(_GetURL_Revision ${FULLURL})
tar zcvf t3-${DATE}-r${REV}.tgz t3
rm -fr t3



