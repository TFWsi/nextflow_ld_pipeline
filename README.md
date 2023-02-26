# Nextflow: Linkage disequilibrium calculation based on VCF files

## Overview

The purpose of the created pipeline is to obtain basic measures characterizing linkage disequilibrium such as coefficients $r^2$, $D$, and $D'$ based on input files in VCF format. Each of the input files is being recoded and filtered based on criteria such as the depth (DP) of the reads, the average depth of reading for all individuals, and the quality of the reads. The X and Y sex chromosomes are also filtered out of the files. Then LD coefficients are calculated for each of the remaining chromosomes separately.

## Materials and methodology

### Input files
Files in compressed .vcf.gz format in standard VCF 4.X. It's required that files contain formatting fields such as QUAL, GT, and DP.

### Tools

#### [VCFtools 0.1.17](https://github.com/vcftools/vcftools)
Recoding and filtering input files:
* min. read depth: 3
* min. mean reads depth: 20
* omit X and Y chromosomes

Calculating LD coefficients:
* maximum distance between SNPs: 5000 BP

#### [Beagle 5.4](http://faculty.washington.edu/browning/beagle/beagle.html)
Haplotypes phasing and imputation

#### PERL
Substitution of some wrongly coded fields which can't be handled by Beagle

#### BASH
Final filtering of the output files from NaN values.

## Results
As the outcome of the entire pipeline, a structure of folders with files containing information on LD measures is obtained for each of the processed files, divided into chromosomes, including data filtered from unknown values and unfiltered data. Files relating to chromosomes are saved in the .hap.ld format containing the following columns:

* CHR - chromosome ID
* POS1 - position of the first SNP
* POS2 - position of the second SNP
* N_CHR - number of chromosomes with info about the locus (samples x 2)
* R2 - LD measurement
* D - LD measurement
* D' - LD measurement
