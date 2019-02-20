#!/usr/bin/perl 
#===========================================================================
#      FILE: check_meanBackgroundDepth_tumor.pl
#      USAGE: perl check_meanBackgroundDepth_tumor.pl UUID Ensembl2Symbol-GrH38.txt all_data_by_genes-PRAD.txt Picked_ExonIntron_6Chrs-gtf-last.bed Homo_sapiens.GRCh38.92.chr.gtf
#
#      AUTHOR: Wang Meng, mengwang55@gmail.com
#      VERSION: 1.0
#      CREATED: 11/18/2016 04:27:55 PM
#      MODIFIED: by AMINA BEDTAT June, 2018
#===========================================================================
use strict;
use warnings;
use List::Util qw/sum/;
use IO::Handle;
use Data::Dumper;
#===========================================================================
my $uuid = $ARGV[0];
my $Ens2Sym = $ARGV[1]; #gene names obtained from bioMart of Ensembl web site
my $alldatabygene = $ARGV[2];
my $exintbed = $ARGV[3];
my $grh38gtf = $ARGV[4];
my $output1=$ARGV[5];
my $output2=$ARGV[6];
my $output3=$ARGV[7];
my $PEIdepth=$ARGV[8];
my $id=$ARGV[9];
#============================================================================
my @parts = split /-/,$id;
##===========================================================================
if ( $parts[3] =~ /01/ ) {
    my $rvalue = &CNV_Ratios_Tumors;
    #print Dumper(\$rvalue);
    &makeDepthbyBase($rvalue);
    &makeDepthbyGene;
}elsif ( $parts[3] !~ /01/ ) {
    my $rvalue = &CNV_Ratios_NONTumors;
    &makeDepthbyBase($rvalue);
    &makeDepthbyGene;
}
##===========================================================================
#Calculate back ground depth per base
##===========================================================================
sub makeDepthbyBase {
    my $rvalue = shift;
    my %value  = %$rvalue;
    my %depth;
    open (I_d, "<$PEIdepth"); #done
    while (<I_d>) {
        chomp;
        my @row = split;
        $depth{ join( "\t", @row[ 0, 1 ] ) } = $row[2];
    }
    open (I_p,"<",$exintbed); #Picked_ExonIntron_6Chrs.bed";
    chdir ($output1);#BackgroundDepth_byBase
    open (O_b1,">bdepthbybase_$id.txt");
    while (<I_p>) {
        chomp;
        my @row = split;
        my @info = split /,/, $row[3];
        next unless $value{ $info[3] };
        map {
            my $d =
                $depth{ join( "\t", $row[0], $_ ) }
              ? $depth{ join( "\t", $row[0], $_ ) }
              : 0;
            #print $row[0], $_, $d, $info[3], $row[4], $value{ $info[3] } ,"\n";
            print O_b1 join( "\t",
                $row[0], $_, $d, $info[3], $row[4], $value{ $info[3] } ),
              "\n";
        } ( $row[1] + 1 ) .. $row[2];
    }
    O_b1->autoflush(1);
}
##===========================================================================
#Calculate the background depth per Gene
##===========================================================================
sub makeDepthbyGene {
    my %depth;
    chdir ($output1);
    open (I_b1, "bdepthbybase_$id.txt ");
    chdir ($output2);#BackgroundDepth_byGene
    open (O_b2, ">bdepthbygene_$id.txt");
    while (<I_b1>) {
        chomp;
        my @row = split;
        push @{ $depth{ join( "\t", @row[ 0, 3, 4, 5 ] ) } }, $row[2];
    }
    for my $k ( keys %depth ) {
        my @d    = @{ $depth{$k} };
        my $mean = sum(@d) / @d;
        print O_b2 join( "\t", $k, $mean ), "\n";
    }
}
##===========================================================================
#Calculate CNV_Ratio in non tumor  #non 01 in the $id
##===========================================================================
sub CNV_Ratios_NONTumors {
    my %symbol2ensembl;
    open (I_en, "<",$Ens2Sym);#Ensembl2symbol.txt;
    while (<I_en>) {
        chomp;
        my @row = split;
        $symbol2ensembl{ $row[1] } = $row[0];
    }
    
    my %value;
    open (I_data, "<",$alldatabygene);#all_data_by_genes.txt";
    while (<I_data>) {
        chomp;
        my @row = split /\t/, $_;
        next unless $symbol2ensembl{ $row[0] };
        my $ensg = $symbol2ensembl{ $row[0] };
        $value{$ensg} = 1;
    }
    \%value;
}
##===========================================================================
#Calculate CNV_Ratio in tumors
##===========================================================================
sub CNV_Ratios_Tumors {
    my %symbol2ensembl;
    open (I_en, "<",$Ens2Sym);#/Ensembl2symbol.txt";
    while (<I_en>) {
        chomp;
        my @row = split;
        $symbol2ensembl{ $row[1] } = $row[0];
    }

    my %chr;
    open (I_gtf, "<",$grh38gtf); #/Homo_sapiens.GRCh37.82.chr.gtf";
    while (<I_gtf>) {
        chomp;
        next if /^#/;
        my @row = split;
        next unless $row[2] eq 'gene';
        my ($ensg) = /gene_id "(ENSG\d+)";/;
        $chr{$ensg} = $row[0];
    }
    my %value;
    
    open (I_data, "<",$alldatabygene); #all_data_by_genes.txt";
    chdir ($output3);
    open (O_f, ">CNV_$id.txt",);
    my $column = 0;
    while (<I_data>) {
        chomp;
        my @row = split /\t/, $_;
        if (/Gene/) {
            map {
                my @name = split /-/, $row[$_];
                my $t = join( "-", @name[ 0, 1, 2 ], "01" );
                $column = $_ if $id =~ /$t/;
            } 3 .. $#row;
        }
        else {
            next unless $symbol2ensembl{ $row[0] };
            my $ensg = $symbol2ensembl{ $row[0] };
            next unless $chr{$ensg};
            $value{$ensg} = ( $row[$column] / 2 ) + 1;
            print O_f join( "\t", $chr{$ensg}, $ensg, $value{$ensg} ), "\n";
        }
    }
    \%value;
}
##===========================================================================

