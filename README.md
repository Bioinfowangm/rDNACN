# Ribosomal DNA Copy Number calculation

The pipeline is constructed in a way to consider data from the TCGA data portal. 

Once the data are downloaded using [gdc-portal](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool), you need to download the sample sheet file that contains information about the samples. The sample sheet file would be used by the function `convertNames.pl` to change the files name, get the  sample's ID (see column `Sample Type`) and the UUID (see column `File ID`).

It is important to note that all the downloaded files are in separate folders and named according the UUID column. More, in each folded there is a bam file named according the file name column. 

## Basic Usage

<p align="center">
<img src="https://github.com/Bioinfowangm/rDNACN/blob/master/images/Diapositive1.png" alt="" width="500" height="550">
</p>

<p align="center">
  <sub>The pipline is build by Meng Wang (2016) at harvard T.H.chan School of public health
  (<a href="http://lemoslab.org">Lemos Lab</a>) and
  <a href="https://github.com/AnimaTardeb"> contributor(A. Bedrat).
  </a>
</p>

![PERL](https://img.shields.io/badge/perl-v5.18.2-blue.svg)
[![License](https://img.shields.io/badge/license-GNU_v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.fr.html)


## Features

- Written in  perl and shell.
- No installation necessary.
- To use, you need to change the paths of the run file.
- Works on Mac and Linux (never tested on Windows).

## Needed files

Make sure to Download (a test data set is already provided in /DATA) and change the path of all the files bellow:

- 45S and 5S consensus sequences [U13369.1](https://www.ncbi.nlm.nih.gov/nuccore/U13369) (see `DATA/rDNA.fa` where both 45S and 5S are in one file).
- rDNA components location (see `DATA/Loci.bed`)
- The sample sheet (see introduction). (The first ligne "title ligne" should be deleted)
- Fastq or bam files. If you use bam files, the tool will extract the fastq sequences aligned on the human genome.
- Human GTF File Format [GRCh38.p12.gtf](https://useast.ensembl.org/Homo_sapiens/Info/Index)
- Single Exons and Introns copy used as genome background [Material and methods].(https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1006994#sec011) (see `DATA/Exon_Intron_6chr.bed`)
- Gene id and names [ensembl/Biomart](http://useast.ensembl.org/biomart/martview/94afd06a2377bb1e93f50d83b3e4bd28)(see `DATA/Ensembl2Symbol-GrH38.txt`).
- Gene-level copy number values for tumor samples [FireBrowse/SNP6 Copy number analysis (GISTIC2)](http://firebrowse.org) (see `DATA/all_data_by_gene_PRAD.txt`).

## Used tools 
- bamUtil
- BWA 
- samtools
- GATK
- perl

## Usage
The pipeline runs on two steps:

### Alignenent and depth calculation
#### To run the first step:

```bash
$ cd PATH/TO/RUN1.sh
$ RUN1.sh
```
This step will: 
- Extract and map reads onto the rDNA consensus sequences (rDNA.fa).
- Estimate the rDNA and the exon/intron background depth.
- Calling variants. 

After this step, X files are generated. They are used through the second step.

### Copy number calculation:
#### To run the second step:

```bash
#YOU NEED TO CHANGE THE:
#UUID =>Line 4
#Specify the path of the results output folders (line 9)
#THE PATH OF THE 14 FILES (from line 20 to 35)
#Know you can run 

$ cd PATH/TO/RUN2.sh
$ RUN2.sh
```
This step will:
- Calculate the depth of the rDNA componenents (18S, 5.8S, 28S and 5S).
- Calculate the backgroud depth for tumor and normal samples.
- Calculate the exons and intron mean Background depth.
- Calculate the rDNA copy number.

## Results:
The rDNA copy number is summerized in the file rDNA_CN/CN-sampleID.txt

```
rDNA_subunit	Background_Depth	rDNA_Depth	rDNA_CN	Type
18mS	24.22	13.8352214212152	0.571231272552238	exon
18mS	3.47	13.8352214212152	3.98709551043666	intron
18mS	13.85	13.8352214212152	0.999293710452524	meanEX-IN

```

## Contributing

#### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/Bioinfowangm/rDNACN/issues) to report any bugs or file feature requests.

