#!/bin/bash

set -eu
#set -o pipefail  # tr seems to be exiting non-zero, but I don't understand why

usage() {
		echo "args: (text|binary) <kibibytes>" >&2
		exit 1
}
if [ $# -ne 2 ]; then
	usage
fi

TYPE="$1"
KIB="$2"

if [ "$TYPE" == "text" ]; then
	FILTER="tr -c -d '[:alnum:]'"
	FOLD="fold"
	EXTENSION="txt"
elif [ "$TYPE" == "binary" ]; then
	FILTER="cat"
	FOLD="cat"
	EXTENSION="bin"
else
	usage
fi

BYTES="$(printf %.0f "$( echo "$KIB * 1024" | bc )")"

FILENAME="${KIB}KiB.$EXTENSION"

export LC_CTYPE=C
cat /dev/urandom | $FILTER | $FOLD | head -c "$BYTES" > "$FILENAME"

echo "$FILENAME"

