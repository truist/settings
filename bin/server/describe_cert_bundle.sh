#!/bin/sh

set -e

hbopenssl storeutl -noout -text -certs "$1"
