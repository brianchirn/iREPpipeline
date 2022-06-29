#!/bin/bash
MAINDIR=$PWD

#Declare a string array
SampleArray=("SampleNameReplace")

CONTPATH="/assembly/02_assembly/02_metaspades/"
CONTfa="contigs.fasta"

PROCPATH="/preprocessing/01_processing/05_sync/"
PROC1gz="_1.fq.gz"
PROC2gz="_2.fq.gz"
tmpStr="/"
# regex .+?(?=\_R[1-2]\.[fastq]+\.[gz]+)
 
# Print array values in  lines
for val1 in ${SampleArray[*]}; do
	CONTIG="$MAINDIR$CONTPATH$val1$tmpStr$CONTfa"
	FASTQ1="$MAINDIR$PROCPATH$val1$PROC1gz"
	FASTQ2="$MAINDIR$PROCPATH$val1$PROC2gz"
	echo -e $val1'\t'$CONTIG'\t'$FASTQ1','$FASTQ2 >> binning_input.txt 
done
