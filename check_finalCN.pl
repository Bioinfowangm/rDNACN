#!/usr/bin/perl 
#===========================================================================
#
#         FILE: check_finalCN.pl
#        USAGE: perl check_finalCN.pl  
#
#       AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/18/2016 09:54:22 PM
#===========================================================================

use strict;
use warnings;
use Statistics::Basic qw(:all);

my $uuid = $ARGV[0];

#require "/n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/convertNames.pl"; #done
require "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Script/convertNames.pl"; #done
my $id   = &process_sampleid($uuid);
my (%chr,%backgrounddepth, %backgrounddepthex);

#////////////////////////////////////
#chdir"/n/regal/lemos_lab/abedrat/TCGAProstate/RESULTS/ResultsPRAD_$uuid/mean_BackgroundDepth";
chdir "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results/ResultsPRAD_$uuid/mean_BackgroundDepth";
open (I_BRD,"<backgdepth$id.txt");
#while(<I_BRD>){
#    chomp;
#    my @row1 = split;
    
#   push @{$chr{$row[0]}},$row[5];
#}
#for my $k(keys %chr){
#    my $mean = mean @{$chr{$k}};
#   $backgrounddepth{$k} = $mean;
#    print $k ,"\n", $mean,"\n";
#}

while(<I_BRD>){
    chomp;
    my @row = split;
    
    push @{$chr{$row[0]}},$row[5];
}
for my $k(keys %chr){
    my $mean = mean @{$chr{$k}};
    $backgrounddepth{$k} = $chr{$k}[1]; #intron
    $backgrounddepthex{$k} = $chr{$k}[0]; #exon
    print $k ,"\t", $backgrounddepth{$k},"\n";
    print $k ,"\t", $backgrounddepthex{$k},"\n";
}

#////////////////////////////////////
#chdir "/n/regal/lemos_lab/abedrat/TCGAProstate/RESULTS/ResultsPRAD_$uuid/mean_rDNAdepth";
chdir "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results/ResultsPRAD_$uuid/mean_rDNAdepth";
open (I_rDNAD,"<mrdnad$id.txt");
#////////////////////////////////////
#chdir "/n/regal/lemos_lab/abedrat/TCGAProstate/RESULTS/ResultsPRAD_$uuid/CNV_Ratios";
chdir "/Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results/ResultsPRAD_$uuid/rDNA_CN";
open (O_f,">CN-$id.txt");
#////////////////////////////////////
print O_f join("\t",qw/rDNA_subunit Background_Depth rDNA_Depth rDNA_CN Type/),"\n";
while(<I_rDNAD>){
    chomp;
    my @row = split;
    if($row[0] eq '5S'){
        print O_f join("\t",$row[0],$backgrounddepthex{"chr1"},$row[1],$row[1]/$backgrounddepthex{"chr1"}, "exon"),"\n"; #chr1 a remplace 1
        print O_f join("\t",$row[0],$backgrounddepth{"chr1"},$row[1],$row[1]/$backgrounddepth{"chr1"},"intron"),"\n"; #chr1 a remplace 1

    }
    else{
        print $row[1],"\n";
        print O_f join("\t",$row[0],$backgrounddepthex{"Combined"},$row[1],$row[1]/$backgrounddepthex{"Combined"}, "exon"),"\n";
        print O_f join("\t",$row[0],$backgrounddepth{"Combined"},$row[1],$row[1]/$backgrounddepth{"Combined"}, "intron"),"\n";
    }
}
