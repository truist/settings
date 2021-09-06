#!/usr/bin/env perl

use warnings;
use strict;
use v5.14;

use Getopt::Long;
use IPC::Open2;
use List::Util qw(max sum);

# distantly based on the original answer at https://stackoverflow.com/questions/1029969/why-is-my-git-repository-so-big/45366030#45366030

sub usage {
    STDERR->say("Usage: $0 [--sum | -s] [--directories | -d] [--[no]human | -h]");
    exit 1;
}

sub parseArgs {
    my ($directories, $sum, $human);

    $human = 1;
    GetOptions('sum' => \$sum, 'directories' => \$directories, 'human!' => \$human)
        or usage();

    if ($directories && !$sum) {
        STDERR->say("Auto-enabling --sum because you used --directories");
        $sum = 1;
    }

    return ($directories, $sum, $human);
}

my $format_bytes;
sub formatBytes {
    my ($human, $bytes) = @_;

    if ($human && !$format_bytes) {
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

    # output is: "<hash> <type> <size>"
    my $pid = open2(my $childOut, my $childIn, "git cat-file --batch-check");

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

sub sumOrMaxSizes {
    my ($sum, %pathSizes) = @_;

    while (my ($path, $sizes) = each %pathSizes) {
        $pathSizes{$path} = $sum ? sum(@{$sizes}) : max(@{$sizes});
    }

    return %pathSizes;
}

sub sortAndPrint {
    my ($human, %pathSizes) = @_;

    my @sortedPaths = sort { $pathSizes{$a} <=> $pathSizes{$b} } keys %pathSizes;
    for my $path (@sortedPaths) {
        printf("%s\t%s\n", formatBytes($human, $pathSizes{$path}), $path);
    }
}

sub main {
    my ($directories, $sum, $human) = parseArgs();

    my %gitObjects = getGitObjects();
    my %hashSizes = getHashSizesForBlobs(keys %gitObjects);
    my %pathSizes = getAllSizesForPaths(\%gitObjects, \%hashSizes);

    %pathSizes = mergeDirectories(%pathSizes) if $directories;
    %pathSizes = sumOrMaxSizes($sum, %pathSizes);
    sortAndPrint($human, %pathSizes);
}

main();


