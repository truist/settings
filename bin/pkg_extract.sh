#!/usr/bin/env bash

set -e

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
	echo "args: <path/to/some.pkg>" >&2
	exit 1
fi

PKGPATH="$1"

DIRNAME="$(dirname "$PKGPATH")"
BASENAME="$(basename "$PKGPATH" ".pkg")"

EXTRACTDIR="$DIRNAME/$BASENAME"

echo "Extracting into $EXTRACTDIR..."
pkgutil --expand "$PKGPATH" "$EXTRACTDIR"

cd "$EXTRACTDIR"
find . -type f -name Payload -exec sh -c 'echo "Extracting $1" ; gzip -d -S "" --stdout "$1" | cpio -i' shell {} \;

find . -type f -name "*.pkg" -exec sh -c 'echo "Extracting $1" ; pkg_extract.sh "$1"' shell {} \;

echo "Done"

