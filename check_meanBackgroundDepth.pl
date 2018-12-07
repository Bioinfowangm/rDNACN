#!/usr/bin/perl 
#===========================================================================
#
#         FILE: check_meanBackgroundDepth.pl
#        USAGE: perl check_meanBackgroundDepth.pl  
#
#       AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/18/2016 02:59:20 PM
#===========================================================================
use strict;
use warnings;
use Statistics::Basic qw(:all);

my $uuid = $ARGV[0];

#require "/n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/convertNames.pl"; #done
require "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Script/convertNames.pl"; #done

my $id   = &process_sampleid($uuid);
print $id;
my %depth;

#chdir "/n/regal/lemos_lab/abedrat/TCGAProstate/RESULTS/ResultsPRAD_$uuid/BackgroundDepth_byBase";
chdir "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results/ResultsPRAD_$uuid/BackgroundDepth_byBase";
open (I_b,"<bdepthbybase_$id.txt");

#chdir "/n/regal/lemos_lab/abedrat/TCGAProstate/RESULTS/ResultsPRAD_$uuid/mean_BackgroundDepth";
chdir "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results/ResultsPRAD_$uuid/mean_BackgroundDepth";
open (O_f,">backgdepth$id.txt");

my (%Depth,%Ratio,%AdjustDepth);
while (<I_b>) {
    chomp;
    my @row = split;
    push @{$Depth{join("\t",@row[0,4])}},$row[2];
    push @{$Ratio{join("\t",@row[0,4])}},$row[5];
    push @{$Depth{join("\t","Combined",$row[4])}},$row[2] if $row[0] ne "chr1"; # ne chr1 a remplace !=1
    push @{$Ratio{join("\t","Combined",$row[4])}},$row[5] if $row[0] ne "chr1"; #
    push @{$AdjustDepth{join("\t",@row[0,4])}},$row[2]/$row[5];
    push @{$AdjustDepth{join("\t","Combined",$row[4])}},$row[2]/$row[5] if $row[0] ne "chr1";
}

print O_f join("\t",qw/Chr Region NonAdjustDepth_mean NonAdjustDepth_median NonAdjustDepth_sd AdjustDepth_mean AdjustDepth_median AdjustDepth_sd Ratio_mean/),"\n";
for my $k(sort keys %Depth){
    my $Depth_mean = mean @{$Depth{$k}};
    my $Depth_median = median @{$Depth{$k}};
    my $Depth_sd = stddev @{$Depth{$k}};
    my $Ratio_mean = mean @{$Ratio{$k}};
    my $AdjustDepth_mean = mean @{$AdjustDepth{$k}};
    my $AdjustDepth_median = median @{$AdjustDepth{$k}};
    my $AdjustDepth_sd = stddev @{$AdjustDepth{$k}};
    print O_f join("\t",$k,$Depth_mean,$Depth_median,$Depth_sd,$AdjustDepth_mean,$AdjustDepth_median,$AdjustDepth_sd,$Ratio_mean),"\n";
}

