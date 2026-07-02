#!/usr/bin/env bash

# shellcheck disable=SC2086
sed -E 's/\x1b\[[0-9;]*[[:alpha:]]//g' $1
