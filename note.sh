#!/bin/sh

set -e

DELETING=0
if [ "-d" == "$1" ]; then
	DELETING=1
	shift
fi

FILE="$*"
if [ ! -z "$FILE" ] && echo "$FILE" | grep -v -q "\." ; then
	FILE="$FILE.txt"
fi

NOTEDIR="$HOME/OneDrive/Scratch"
cd "$NOTEDIR"

if [ "$DELETING" == 1 ]; then
	git rm "$FILE" && git commit -m "delete $FILE"
elif [ -f "$FILE" ]; then
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

# be prepared in case they background vi during the edit session
wait

if [ -f "$FILE" ]; then
	git add "$FILE" && git commit -m "update $FILE"
fi

