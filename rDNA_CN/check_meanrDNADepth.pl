#!/usr/bin/perl 
#===========================================================================
#      FILE: check_meanrDNADepth.pl
#      USAGE: perl check_meanrDNADepth.pl $uuid $input1 $input2 $output1
#
#      AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/18/2016 02:49:45 PM
#      MODIFIED: by AMINA BEDTAT June, 2018
#===========================================================================
use strict;
use warnings;
use List::Util qw/sum/;
##===========================================================================
my $uuid = $ARGV[0]; #uuid
my $locibed=$ARGV[1];
my $rdnadepth=$ARGV[2];
my $output=$ARGV[3]; #mean_rDNAdepth"
my $id=$ARGV[4];
##===========================================================================
## Calculate rDNA depth
##===========================================================================
my ( %depth, $sumdepth45S, $length45S,$sumdepth45S_457 );
open (I_rd, "<",$rdnadepth);
while (<I_rd>) {
    chomp;
    my @row = split;
    $depth{ join( ",", @row[ 0, 1 ] ) } = $row[2];
    $sumdepth45S += $row[2] if $row[0] =~ /U13369/ && $row[1] > 6534;
    $sumdepth45S_457 += $row[2] if $row[0] =~ /U13369/ && (($row[1]>6778 && $row[1]<=6928)||($row[1]>8600 && $row[1]<=8757) ||($row[1]>11433 && $row[1]<=11583));
}
open (I_reg, "<",$locibed); #done
chdir ($output);
use Cwd;
my $dir = getcwd();
print "$dir\n";
open (O_f1, ">mrdnad$id.txt");
while (<I_reg>) {
    chomp;
    next if /18S$/;
    my @row = split;
    my @number;
    map {
        push @number,
          $depth{ join( ",", $row[0], $_ ) }
          ? $depth{ join( ",", $row[0], $_ ) }
          : 0
    } ( $row[1] + 1 ) .. $row[2];
    my $mean = sum(@number) / @number;
    print O_f1 "$row[3]\t$mean\n";
    $length45S += ( $row[2] - $row[1] ) if $row[3] eq '18mS' || $row[3] eq '5.8S' || $row[3] eq '28S';
}
my $meandepth45S = $sumdepth45S / $length45S;
my $meandepth45S_457 = $sumdepth45S_457 /457;
print O_f1 "45S\t$meandepth45S\n";
print O_f1 "45S_457\t$meandepth45S_457\n";
system("cd ../..");
##===========================================================================
