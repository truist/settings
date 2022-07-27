#!/bin/sh

set -e

hbopenssl x509 -noout -modulus -in "$1" | hbopenssl md5

