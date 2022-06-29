#!/bin/bash
#apply loop function to samples

dir=$PWD

for SAMPLE in *_[1].fastq.gz
do
#loop through all _1.fasstq.gz samples
FL1=${SAMPLE}
SampName=${FL1%_*} #get SampName
echo $SampName
mkdir $SampName
mkdir ${SampName}/data
mv ${SampName}_1.fastq.gz ${SampName}/data
mv ${SampName}_2.fastq.gz ${SampName}/data
done
