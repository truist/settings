#!/usr/bin/env bash

for PROC in network_test nc ncat ping curl ; do
	ps x | grep $PROC | awk '{ print $1 }' | xargs kill
done
