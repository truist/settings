#!/usr/bin/env bash

set -e

if [[ $# -ne 2 ]]; then
	echo "args: <range> <report name>" >&2
	exit 1
fi

RANGE="$1"
NAME="$2"

nmap -p 22 -Pn --open -A -oG "$NAME.temp" "$RANGE"

grep -v "Status: Up" "$NAME.temp" > "$NAME.gnmap"
rm "$NAME.temp"

echo "Done!"

