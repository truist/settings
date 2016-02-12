#!/bin/sh

if [ -n "$BASH_SOURCE" ]; then
  SOURCE="${BASH_SOURCE}"
else
  SOURCE="$0"
fi
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  if [ "$SOURCE" != "/*" ]; then
    SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo $DIR

