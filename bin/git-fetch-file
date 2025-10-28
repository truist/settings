#!/bin/sh

set -e

if [ $# -ne 3 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "args: <remote> <ref> <path/to/file>" >&2
	echo "    <ref> must be a ref, not a commit SHA" >&2
	exit 1
fi

git archive --remote="$1" "$2" "$3" | tar xO

