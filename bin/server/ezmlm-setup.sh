#!/bin/sh

set -eu

if [ $# -lt 2 ]; then
	echo "args: <list name> <subscribers file> <extra ezmlm-make args>" >&2
	echo "    (try using '-e' to edit an exiting list)"
	exit 1
fi
LIST=$1 ; shift
SUBSCRIBERS="$1" ; shift
EXTRAS="$@"

if ! test -f "$SUBSCRIBERS" ; then
	echo "$SUBSCRIBERS is not a file" >&2
	exit 2
fi

ALIAS=/etc/qmail/alias
DOMAIN=rainskit.com

OWNER=narthur-list-$LIST-owner@$DOMAIN
MODERATOR=narthur-list-$LIST-moderator@$DOMAIN

echo "Making a private list with no archive that only subscribers can post to (without moderation)..."
if test -n "$EXTRAS" ; then
	echo "    (plus the extra settings: $EXTRAS)"
fi
ezmlm-make -P -A -u -m -5 $MODERATOR $EXTRAS $ALIAS/$LIST $ALIAS/.qmail-$LIST $LIST $DOMAIN

echo "Configuring the list so replies go to the list, not to the sender..."
touch $ALIAS/$LIST/replytolist

echo "Subscribing '$SUBSCRIBERS' to the list..."
ezmlm-sub $ALIAS/$LIST < "$SUBSCRIBERS"

echo "Adding $MODERATOR as a moderator..."
ezmlm-sub $ALIAS/$LIST mod $MODERATOR

echo "Fixing up permissions..."
chown -R alias $ALIAS/$LIST
chown -h alias $ALIAS/.qmail-$LIST*

echo "Done!"

