#! /bin/bash

HOMEDIR=build/
HOMEDIRDOC=docs/
HOMEDIR_ORIX=/home/travis/build/oric-software/orix

mkdir -p ../orix/usr/share/basic11/ 

LIST_COMMAND=`ls ../orix/usr/share/basic11/*/*.md`

echo Generate hlp

for I in $LIST_COMMAND
do
	echo Generate $I

	DESTFILE=`basename $I | cut -d '.' -f1`
	DESTFILE="${DESTFILE}.hlp"

	#echo DESFILE
	#echo  "cat $I | python md2hlp/src/md2hlp.py3 -c md2hlp/src/md2hlp.cfg > ../orix/usr/share/basic11/$DESTFILE"

	cat $I | python3 md2hlp/src/md2hlp.py3 -c md2hlp_basic11.cfg > ../orix/usr/share/basic11/$DESTFILE
done 
