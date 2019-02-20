#!/usr/bin/perl
#===========================================================================
#      FILE: check_finalCN.pl
#      USAGE: perl check_finalCN.pl $uuid $outout1 $outout2 $outout3
#
#      AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/18/2016 09:54:22 PM
#      MODIFIED: by AMINA BEDTAT June, 2018
#===========================================================================
use strict;
use warnings;
use Statistics::Basic qw(:all);
#===========================================================================
my $uuid = $ARGV[0];
my $output1=$ARGV[1];
my $output2=$ARGV[2];
my $output3=$ARGV[3];
my $id=$ARGV[4];

my (%chr,%backgrounddepth, %backgrounddepthex, %meanbackgrounddepth);
#===========================================================================

chdir ($output1);
open (I_BRD,"<backgdepth$id.txt");

while(<I_BRD>){
    chomp;
    my @row = split;
    push @{$chr{$row[0]}},$row[5];
}
for my $k(keys %chr){
    my $mean = mean @{$chr{$k}};
    $backgrounddepth{$k} = $chr{$k}[1]; #intron
    $backgrounddepthex{$k} = $chr{$k}[0]; #exon
    $meanbackgrounddepth{$k} = $mean;
}

#===========================================================================
chdir ($output2);
open (I_rDNAD,"<mrdnad$id.txt");
#===========================================================================
chdir ($output3);
open (O_f,">CN-$id.txt");
#===========================================================================
print O_f join("\t",qw/rDNA_subunit Background_Depth rDNA_Depth rDNA_CN Type/),"\n";
while(<I_rDNAD>){
    chomp;
    my @row = split;
    if($row[0] eq '5S'){
        print O_f join("\t",$row[0],$backgrounddepthex{"chr1"},$row[1],$row[1]/$backgrounddepthex{"chr1"}, "exon"),"\n"; #chr1 a remplace 1
        print O_f join("\t",$row[0],$backgrounddepth{"chr1"},$row[1],$row[1]/$backgrounddepth{"chr1"},"intron"),"\n"; #chr1 a remplace 1
        print O_f join("\t",$row[0],$meanbackgrounddepth{"chr1"},$row[1],$row[1]/$meanbackgrounddepth{"chr1"},"meanEX-IN"),"\n"; #chr1 a remplace 1
    }
    else{
        #print $row[1],"\n";
        print O_f join("\t",$row[0],$backgrounddepthex{"Combined"},$row[1],$row[1]/$backgrounddepthex{"Combined"}, "exon"),"\n";
        print O_f join("\t",$row[0],$backgrounddepth{"Combined"},$row[1],$row[1]/$backgrounddepth{"Combined"}, "intron"),"\n";
        print O_f join("\t",$row[0],$meanbackgrounddepth{"Combined"},$row[1],$row[1]/$meanbackgrounddepth{"Combined"}, "meanEX-IN"),"\n";
    }
}

#===========================================================================








