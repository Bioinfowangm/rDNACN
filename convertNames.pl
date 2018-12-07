#!/usr/bin/perl 
#===========================================================================
#         FILE: convertNames.pl
#        USAGE: perl convertNames.pl
#
#       AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/28/2016 10:00:14 PM
#===========================================================================

use strict;
use warnings;


#my $id = &process_sampleid("9da16c35-aa0f-4ca5-86f9-98bc4618a33b");

sub process_sampleid {
    my $uuid = shift;
    print $uuid,"\n";
    my %uuid2id;
    #open I_info, "/n/regal/lemos_lab/abedrat/TCGAProstate/info-files/gdc_sample_sheet.2018-06-15.tsv";
    open (I_info, "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Info/gdc_sample_sheet.2018-06-15.tsv");

    #"/Users/MoiMeamina/Downloads/gdc_sample_sheet.2018-06-15.tsv";
    while (<I_info>) {
        chomp;
        my @row = split /\t/,$_;
#        my @splitted = split /-/,$row[1];
#        $row[5] = "01" if $row[5] == 1;
        $uuid2id{ $row[0] } = $row[6];
    }
    $uuid2id{$uuid};
}

#my $uuid = $ARGV[0];
#my $id = &process_sampleid($uuid);
#print $id;
1;

