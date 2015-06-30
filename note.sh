#!/bin/sh

set -e

FILE="$*"
if echo "$FILE" | grep -v -q "\." ; then
	FILE="$FILE.txt"
fi

NOTEDIR="$HOME/OneDrive/Scratch"
cd "$NOTEDIR"

vi "$FILE"

if [ -f "$FILE" ]; then
	git add "$FILE" && git commit -m "update $FILE"
fi

