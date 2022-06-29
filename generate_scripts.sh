#!/bin/bash
#loop to generate script files based on folder name

dir=$PWD
for d in */ ; do
	SampName=${d%/}
	cp .scripts/* $SampName
	sed -i -e "s/SampleNameReplace/${SampName}/g" ${SampName}/00_all.R
	sed -i -e "s/SampleNameReplace/${SampName}/g" ${SampName}/08_get_irep_values.R
	sed -i -e "s/SampleNameReplace/${SampName}/g" ${SampName}/create_binning_input.txt.sh
	sed -i -e "s/SampleNameReplace/${SampName}/g" ${SampName}/Snakefile
	echo $SampName
done

