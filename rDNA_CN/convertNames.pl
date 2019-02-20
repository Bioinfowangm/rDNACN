#!/usr/bin/perl 
#===========================================================================
#      FILE: convertNames.pl
#
#
#      AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/28/2016 10:00:14 PM
#      MODIFIED: by AMINA BEDTAT June, 2018
#===========================================================================

use strict;
use warnings;

sub process_sampleid {
    my $uuid = shift;
    my %uuid2id;
    open (I_info, $TSVfile);
    while (<I_info>) {
        chomp;
        my @row = split /\t/,$_;
        $uuid2id{ $row[0] } = $row[6];
    }
    return $uuid2id{$uuid};
}

my $uuid = $ARGV[0];
my $TSVfile=$ARGV[1];
my $id= &process_sampleid($uuid);
print $id;
1;
##===========================================================================
