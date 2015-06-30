#!/bin/sh

set -e

FILE="$*"
if [ ! -z "$FILE" ] && echo "$FILE" | grep -v -q "\." ; then
	FILE="$FILE.txt"
fi

NOTEDIR="$HOME/OneDrive/Scratch"
cd "$NOTEDIR"

if [ -f "$FILE" ]; then
	vi "$FILE"
else
	DATESTAMP=$(date +"%a %b %d, %Y - %l:%M %p %Z")
	DATEARG=":normal i$DATESTAMP"
	MODARG=":set nomodified"
	if [ -z "$FILE" ]; then
		vi -c "$DATEARG" -c "$MODARG"
	else
		vi -c "$DATEARG" -c "$MODARG" "$FILE"
	fi
fi

if [ -f "$FILE" ]; then
	git add "$FILE" && git commit -m "update $FILE"
fi

