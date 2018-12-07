#!/bin/bash

#SBATCH -p general
#SBATCH -J download
#SBATCH -n 6 
#SBATCH -N 1
#SBATCH -t 6-00:00
#SBATCH --mem 16000
#SBATCH -o ../Log/Download_Slice_%A_%a.out
#SBATCH -e ../Log/Download_Slice_%A_%a.err


# Loading modules
module load bwa/0.7.9a-fasrc01
module load samtools/1.3.1-fasrc01
module load bamUtil/1.0.13-fasrc01
module load bedtools2/2.25.0-fasrc01

#To run this script :
#sbatch --array=1-30 tophat.sh


# Preparing samples
index=`expr ${SLURM_ARRAY_TASK_ID} - 1`
readarray -t A<../Info/UUIDs.selected
readarray -t B<../Info/Names.selected
UUID=${A[$index]}
name=${B[$index]} #bam files name
prefix=${name%.*}

cd ..
#if test ! -e $UUID/$name
if test ! -e $UUID
then
    gdc-client download -t /n/regal/lemos_lab/wangm/Tumor/Token/gdc-user-token.2016-12-02T00_17_23-05_00.txt $UUID -n 6 
fi

#cd $UUID
#samtools view -b -L /n/regal/lemos_lab/wangm/Tumor/Information/Picked_ExonIntron_6Chrs.bed $name -o Picked_ExonIntron_6Chrs.bam
#samtools view -b -L /n/regal/lemos_lab/wangm/Tumor/Information/rDNA_slice.bed $name -o rDNA_slice.bam

#rm $name
