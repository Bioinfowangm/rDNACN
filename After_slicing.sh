#!/bin/bash

#SBATCH -p general                   #partition
#SBATCH -J align_sort                  #A single job name for the array
#SBATCH -n 6                         #Number of cores
#SBATCH -N 1                         #All cores in one machine
#SBATCH -t 6-00:00                   #max execution time
#SBATCH --mem 16000                  #memory request
#SBATCH -o ../log/align_sort.out # std output
#SBATCH -e ../log/align_sort.err # std err

# Loading modules
module load bwa/0.7.15-fasrc02
module load samtools/1.5-fasrc02
module load bamUtil/1.0.13-fasrc01
module load bedtools2/2.26.0-fasrc01

#runing this script
#sbatch --array=1-30 After_splicing.sh #1-30 should be variable

# Preparing samples
index=`expr ${SLURM_ARRAY_TASK_ID} - 1`
readarray -t A</n/regal/lemos_lab/abedrat/TCGAProstate/info-files/UUIDs.selected
readarray -t B</n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Names.selected #bam file names
UUID=${A[$index]}
name=${B[$index]}
prefix=${name%.*}
TCGA=TCGA-HNSC

cd /n/regal/lemos_lab/abedrat/TCGAProstate/scripts/$UUID

#bam to fastq
#bam bam2FastQ --in rDNA_slice.bam #generate 3 files  rDNA_slice_1.fastq, rDNA_slice_2.fastq and rDNA_slice.fastq
bam bam2FastQ --in $name #generate 3 files  rDNA_slice_1.fastq, rDNA_slice_2.fastq and rDNA_slice.fastq

reads=`head -2 $prefix"_1.fastq"|tail -1`
length=${#reads}

#remove already calculated files if necessairy
if test -e $prefix"_1.sai"
then
    rm $prefix"_1.sai" $prefix"_2.sai" $prefix".sai" Sliced2sequence_PE.bam Sliced2sequence_SE.bam SE_PE_Fq_AlignedrDNA.bam SE_PE_Fq_AlignedrDNA_sorted.bam
fi
# mapping fastq to rDNA sequences, then sort
if test $length -gt 70
then
    bwa mem -t 6 -T 0 /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix"_1.fastq" $prefix"_2.fastq"|samtools view -hb -F 4 -o Sliced2sequence_PE.bam -
    bwa mem -t 6 -T 0 /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix".fastq" |samtools view -hb -F 4 -o Sliced2sequence_SE.bam -
else
    bwa aln -t 6 /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix"_1.fastq" > $prefix"_1.sai"
    bwa aln -t 6 /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix"_2.fastq" > $prefix"_2.sai"
    bwa aln -t 6 /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix".fastq" > $prefix".sai"
    bwa sampe /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix"_1.sai" $prefix"_2.sai"  $prefix"_1.fastq" $prefix"_2.fastq"|samtools view -hb -F 4 -o Sliced2sequence_PE.bam -
    bwa samse /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Both.fa $prefix".sai" $prefix".fastq"|samtools view -hb -F 4 -o Sliced2sequence_SE.bam -
fi

#Merge and sort + name changes
#Sliced2sequence.bam => SE_PE_Fq_AlignedrDNA.bam

samtools merge SE_PE_Fq_AlignedrDNA.bam Sliced2sequence_PE.bam Sliced2sequence_SE.bam
samtools sort -m 4G -O bam -T middle -@ 6 -o SE_PE_Fq_AlignedrDNA_sorted.bam SE_PE_Fq_AlignedrDNA.bam

# calculate depth of rDNA regions, as well as background regions

samtools depth -d 1000000 -b /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/loci.bed SE_PE_Fq_AlignedrDNA_sorted.bam >rDNA.depth

#Convert bed to bam the to depth
samtools view -b -L /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Picked_ExonIntron_6Chrs.bed $name -o Picked_ExonIntron_6Chrs.bam
samtools depth -d 1000000 -b /n/regal/lemos_lab/abedrat/TCGAProstate/info-files/Picked_ExonIntron_6Chrs.bed Picked_ExonIntron_6Chrs.bam >Picked_ExonIntron_6Chrs.depth


#perl /n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/check_meanrDNADepth.pl $UUID $TCGA
#perl /n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/check_baseBackgroundDepth_tumor.pl $UUID $TCGA
#perl /n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/check_baseBackgroundDepth_normal.pl $UUID $TCGA
#perl /n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/check_meanBackgroundDepth.pl $UUID $TCGA
#perl /n/regal/lemos_lab/abedrat/TCGAProstate/SCRIPTS-S/check_finalCN.pl $UUID $TCGA

rm *fastq
rm *.sai
rm Sliced2sequence_PE.bam
rm Sliced2sequence_SE.bam
