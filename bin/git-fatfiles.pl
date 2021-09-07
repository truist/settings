#!/usr/bin/env perl

use warnings;
use strict;
use v5.14;

use Getopt::Long;
use IPC::Open2;
use List::Util qw(max sum);

# distantly based on the original answer at https://stackoverflow.com/questions/1029969/why-is-my-git-repository-so-big/45366030#45366030

sub usage {
    my ($exitCode) = @_;

    STDERR->say("args: [(--help | -h) | ([(--directories | -d) | (--[no]sum | -s)] [--deleted | -d] [--[no]units | -u])]");
    STDERR->say("\t");
    STDERR->say("\tYou might want to run `git gc --prune=now --aggressive` before running this script.");
    STDERR->say("\t");
    STDERR->say("\tNo args (equivalent to `--sum --units`):");
    STDERR->say("\t\tshow the sum of the on-disk (compressed) sizes for all objects in the history, for each path");
    STDERR->say("\t--directories: aggregate results by directory");
    STDERR->say("\t--nosum: show the size of the largest object in the history, rather than the sum of all objects, for each path");
    STDERR->say("\t--deleted: only show results for paths that are not in the current working directory");
    STDERR->say("\t--nounits: show results in bytes, not larger units");

    exit $exitCode;
}

sub parseArgs {
    my ($directories, $sum, $deleted, $units, $help);

    $sum = 1;
    $units = 1;
    GetOptions('sum!' => \$sum, 'directories' => \$directories, 'deleted' => \$deleted, 'units!' => \$units, 'help' => \$help)
        or usage(1);

    usage(0) if $help;

    return ($directories, $sum, $deleted, $units);
}

my $format_bytes;
sub formatBytes {
    my ($units, $bytes) = @_;

    if ($units && !$format_bytes) {
        # Try to get the "format_bytes" function:
        my $canFormat = eval {
            require Number::Bytes::Human;
            Number::Bytes::Human->import('format_bytes');
            1;
        };
        if ($canFormat) {
            $format_bytes = \&format_bytes;
        } else {
            STDERR->say("Could not load Number::Bytes::Human; output will be in bytes");
        }
    }

    if (!$format_bytes) {
        $format_bytes = sub { return shift; };
    }

    return $format_bytes->($bytes);
}


## ------------------------------- ##


sub getGitObjects {
    # hash => path
    my %gitObjects;
    for my $line (qx(git rev-list --all --objects)) {
        my ($hash, $path) = split(' ', $line, 2);
        $gitObjects{$hash} = $path =~ s|\s+$||r;  # trim trailing whitespace
    }
    return %gitObjects;
}

sub getHashSizesForBlobs {
    my (@hashes) = @_;

    my $pid = open2(my $childOut, my $childIn, "git cat-file --batch-check='%(objectname) %(objecttype) %(objectsize:disk)'");

    # hash => size
    my %hashSizes;
    for my $hash (@hashes) {
        $childIn->say($hash);

        my ($hash, $type, $size) = split(' ', $childOut->getline());
        if ($type eq 'blob') {
            $hashSizes{$hash} = $size;
        }
    }

    close($childIn);
    waitpid($pid, 0);

    return %hashSizes;
}

sub getAllSizesForPaths {
    my ($gitObjects, $hashSizes) = @_;

    # path => [size, ...]
    my %pathSizes;
    while (my ($hash, $path) = each %{$gitObjects}) {
        # filter out directories
        next unless exists $hashSizes->{$hash};

        my $sizes = $pathSizes{$path} || [];
        push(@{$sizes}, $hashSizes->{$hash});
        $pathSizes{$path} = $sizes;
    }

    return %pathSizes;
}

sub mergeDirectories {
    my (%pathSizes) = @_;

    # dir => [size, ...]
    my %dirSizes;
    while (my ($path, $sizes) = each %pathSizes) {
        my $pathOnly = $path =~ s|/[^/]*$||r;  # strip the filename part
        if (exists $dirSizes{$pathOnly}) {
            push(@{$sizes}, @{$dirSizes{$pathOnly}});
        }
        $dirSizes{$pathOnly} = $sizes;
    }

    return %dirSizes;
}

sub removeDeleted {
    my (%pathSizes) = @_;

    for my $path (keys %pathSizes) {
        delete $pathSizes{$path} if -e $path || -l $path;
    }

    return %pathSizes;
}

sub sumOrMaxSizes {
    my ($sum, %pathSizes) = @_;

    while (my ($path, $sizes) = each %pathSizes) {
        $pathSizes{$path} = $sum ? sum(@{$sizes}) : max(@{$sizes});
    }

    return %pathSizes;
}

sub sortAndPrint {
    my ($units, %pathSizes) = @_;

    my @sortedPaths = sort { $pathSizes{$a} <=> $pathSizes{$b} } keys %pathSizes;
    for my $path (@sortedPaths) {
        printf("%s\t%s\n", formatBytes($units, $pathSizes{$path}), $path);
    }
}

sub main {
    my ($directories, $sum, $deleted, $units) = parseArgs();

    my %gitObjects = getGitObjects();
    my %hashSizes = getHashSizesForBlobs(keys %gitObjects);
    my %pathSizes = getAllSizesForPaths(\%gitObjects, \%hashSizes);

    %pathSizes = mergeDirectories(%pathSizes) if $directories;
    %pathSizes = removeDeleted(%pathSizes) if $deleted;
    %pathSizes = sumOrMaxSizes($sum, %pathSizes);
    sortAndPrint($units, %pathSizes);
}

main();


