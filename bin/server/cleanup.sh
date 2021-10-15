#!/bin/sh

set -e

dpkg --get-selections | \
  grep 'linux-image*' | \
  awk '{print $1}' | \
  egrep -v "linux-image-$(uname -r)|linux-image-generic" | \
  while read n
  do
    apt-get -y remove $n
  done

apt purge `dpkg --list | grep ^rc | awk '{ print $2; }'`

