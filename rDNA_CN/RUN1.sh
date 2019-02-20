#!/bin/bash
#############################################################################
#############################################################################
UUID="b469215a-7486-4411-b9b9-a605b9097c16"
echo $UUID
#----------------------------------------
#Creat the Results repository
#----------------------------------------
cd /Volumes/AMINABE/0-2018-RNASEQ/TCGA-HNSC/Results
mkdir -p ResultsPRAD_$UUID ; cd ResultsPRAD_$UUID
mkdir -p mean_rDNADepth;
mkdir -p BackgroundDepth_byBase;
mkdir -p BackgroundDepth_byGene;
mkdir -p CNV_Ratios;
mkdir -p mean_BackgroundDepth;
mkdir -p rDNA_CN;
#----------------------------------------
#Path to all used file
#----------------------------------------
locibed ="/PATH/TO/loci.bed"
TSVfile ="/PATH/TO/gdc_sample_sheet.2018-06-15.tsv"
PATHE2S ="/PATH/TO/Ensembl2Symbol-GrH38.txt"
EIDB    ="/PATH/TO/all_data_by_genes-PRAD.txt"
EIbed   ="/PATH/TO/HG38-Picked_ExonIntron_6Chr.bed"
grh38gtf="/PATH/TO/Homo_sapiens.GRCh38.92.chr.gtf"

rdnadepth   ="/PATH/TO/$UUID/rDNA.depth"
PEIdepth    ="/PATH/TO/$UUID/Picked_ExonIntron_6Chrs.depth"

output0="/PATH/TO/ResultsPRAD_$UUID/mean_rDNADepth/"
output1="/PATH/TO/ResultsPRAD_$UUID/BackgroundDepth_byBase"
output2="/PATH/TO/ResultsPRAD_$UUID/BackgroundDepth_byGene"
output3="/PATH/TO/ResultsPRAD_$UUID/CNV_Ratios"
output4="/PATH/TO/ResultsPRAD_$UUID/mean_BackgroundDepth"
output5="/PATH/TO/ResultsPRAD_$UUID/rDNA_CN"

######################################################################################################

id=$(perl /PATH/TO/convertNames.pl $UUID $TSVfile)
echo "THE sample is :  $id"

#====================================================
##Calculate rDNA depth
#====================================================
#echo $UUID
#cd /PATH/TO/$UUID
# perl check_meanrDNADepth.pl UUID LOCI.bed rDNA.depth outputpath
echo "Calculating rDNA depth "
perl /PATH/TO/check_meanrDNADepth.pl $UUID $locibed $rdnadepth $output0 $id
#====================================================
##Calculate base background depth in normal and tumor cells
#====================================================
#pwd
echo "Calculating per base background depth"
perl /PATH/TO/check_baseBackgroundDepth_normaltumor.pl $UUID $PATHE2S $EIDB $EIbed $grh38gtf $output1 $output2 $output3 $PEIdepth $id

#====================================================
##Calculate mean background depth
#====================================================
echo "Calculating the mean of background depth"
perl /PATH/TO/check_meanBackgroundDepth.pl $UUID $output1 $output4 $id

#====================================================
#Calculate Final CNV
#====================================================
echo "Calculating the rDNA copy Number (CN) "
perl /PATH/TO/check_finalCN.pl $UUID $output4 $output0 $output5 $id




