#!/bin/sh

set -e

if [ $# -ne 3 ]; then
	echo "args: <output width (pixels)> <input> <output>" >&2
	exit 1
fi

SCALE=$1; shift
INPUT=$1; shift
OUTPUT=$1; shift

palette="/tmp/palette.png"

filters="fps=10,scale=$SCALE:-1:flags=lanczos"

ffmpeg -v warning -i $INPUT -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $INPUT -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $OUTPUT

echo Done!
