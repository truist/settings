#!/bin/bash

set -e

if echo `uname` | grep -E ^Darwin > /dev/null ; then
	echo -n "" # we're on a Mac
else
	echo "sorry, this script was developed to work with Mac 'top'" >&2
	echo "if you want to make it work on your OS, please adjust the 'top' line to work correctly" >&2
	# original source (probably for linux):
	# https://notebookbft.wordpress.com/2016/06/08/shell-script-to-continuously-monitor-cpu-usage-and-memory-usage-of-a-process-and-write-output-to-csv-file/
	exit 1
fi

if [ -z "$1" ]; then
	echo "args: <grep string that will match your process(es), e.g. 'perl'>" >&2
	exit 1
fi

GREPSTR="$1"

echo "Timestamp,Memory"

while :
do
	DATE=`date +"%H:%M:%S"`
	echo -n "$DATE, "
	top -l 1 | grep -w "$GREPSTR" | tr -s ' ' | cut -d ' ' -f 8 | tr '\n' ' '
	echo
	sleep 1
done
