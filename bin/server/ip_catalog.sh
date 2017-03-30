#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
	echo "args: <tinydns data file>" >&2
	exit 1
fi

IPs=$(cat "$1" | awk -F ':' '{ print $2 }' | sort -n -u)
for IP in $IPs; do
	echo "$IP:"
	cat "$1" | awk -F ':' '{ print $2 ":" $1 }' | grep "$IP" | awk -F ':' '{ print "    " $2 }' | sort -u
done
