#!/usr/bin/env perl

use strict;
use warnings;

binmode(STDOUT, ':utf8');

while (<>) {
    s/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg;
    print;
}
