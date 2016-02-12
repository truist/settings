#!/bin/sh

set -e

if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
	echo "args: </path/to/file> <user@host>" >&2
	exit 1
fi
FILEPATH="$1"
FILE=`basename "$FILEPATH"`
RECIPIENTS="$2"

uuencode "$FILEPATH" "$FILE" | mail -s "$FILE" "$RECIPIENTS"

