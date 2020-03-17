#!/bin/sh

set -e

function testit {
	while read LINE; do
		echo "GOT IT: $LINE"
	done
}

if [ $# -eq 0 ]; then
	echo 'args: <host> [<host>...]' 1>&2
	exit 1
fi

echo "DATE,TIME,HOST,LATENCY"
while true; do
	for REMOTE in "$@"; do
		ping -c 1 -t 3 "$REMOTE" 2>&1 | grep 'time=' | awk '{ print $4,$7 }' | sed 's/: time=/,/' | sed -E 's/\.[[:digit:]]+$//' | ts '%F %T' | tr ' ' ','
	done
	sleep 1
done


