#!/usr/bin/env perl
use warnings;
use strict;
use IPC::Open2;
use v5.14;

# from https://stackoverflow.com/questions/1029969/why-is-my-git-repository-so-big/45366030#45366030


# Try to get the "format_bytes" function:
my $canFormat = eval {
    require Number::Bytes::Human;
    Number::Bytes::Human->import('format_bytes');
    1;
};
my $format_bytes;
if ($canFormat) {
    $format_bytes = \&format_bytes;
}
else {
    $format_bytes = sub { return shift; };
}

# parse arguments:
my ($directories, $sum);
{
    my $arg = $ARGV[0] // "";
    if ($arg eq "--sum" || $arg eq "-s") {
        $sum = 1;
    }
    elsif ($arg eq "--directories" || $arg eq "-d") {
        $directories = 1;
        $sum = 1;
    }
    elsif ($arg) {
        print "Usage: $0 [ --sum, -s | --directories, -d ]\n";
        exit 1;
    } 
}

# the format is [hash, file]
my %revList = map { (split(' ', $_))[0 => 1]; } qx(git rev-list --all --objects);
my $pid = open2(my $childOut, my $childIn, "git cat-file --batch-check");

# The format is (hash => size)
my %hashSizes = map {
    print $childIn $_ . "\n";
    my @blobData = split(' ', <$childOut>);
    if ($blobData[1] eq 'blob') {
        # [hash, size]
        $blobData[0] => $blobData[2];
    }
    else {
        ();
    }
} keys %revList;
close($childIn);
waitpid($pid, 0);

# Need to filter because some aren't files--there are useless directories in this list.
# Format is name => size.
my %fileSizes =
    map { exists($hashSizes{$_}) ? ($revList{$_} => $hashSizes{$_}) : () } keys %revList;


my @sortedSizes;
if ($sum) {
    my %fileSizeSums;
    if ($directories) {
        while (my ($name, $size) = each %fileSizes) {
            # strip off the trailing part of the filename:
            $fileSizeSums{$name =~ s|/[^/]*$||r} += $size;
        }
    }
    else {
        while (my ($name, $size) = each %fileSizes) {
            $fileSizeSums{$name} += $size;
        }
    }

    @sortedSizes = map { [$_, $fileSizeSums{$_}] }
        sort { $fileSizeSums{$a} <=> $fileSizeSums{$b} } keys %fileSizeSums;
}
else {
    # Print the space taken by each file/blob, sorted by size
    @sortedSizes = map { [$_, $fileSizes{$_}] }
        sort { $fileSizes{$a} <=> $fileSizes{$b} } keys %fileSizes;

}

for my $fileSize (@sortedSizes) {
    printf "%s\t%s\n", $format_bytes->($fileSize->[1]), $fileSize->[0];
}
