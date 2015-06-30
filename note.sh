#!/bin/sh

set -e

FILE="$*"
if echo "$FILE" | grep -v -q "\." ; then
	FILE="$FILE.txt"
fi

NOTEDIR="$HOME/OneDrive/Scratch"
cd "$NOTEDIR"


if [ -f "$FILE" ]; then
	vi "$FILE"
else
	DATESTAMP=$(date +"%a %b %d, %Y - %l:%M %p %Z")
	vi -c ":normal i$DATESTAMP" "$FILE"
fi

if [ -f "$FILE" ]; then
	git add "$FILE" && git commit -m "update $FILE"
fi

