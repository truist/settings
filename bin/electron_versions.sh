#!/usr/bin/env bash

set -e

for filename in /Applications/*.app/Contents/Frameworks/Electron\ Framework.framework/Electron\ Framework ; do
	echo "$filename: "
	echo -n "  "
	strings "$filename" | grep "Chrome/" | grep -i Electron | grep -v '%s' | sort -u
done

