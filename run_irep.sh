#!/bin/bash
#loop through each directory and sbatch 00_all.R

for d in */ ; do
	SampName=${d%/}
	cd $SampName
	sbatch 00_all.R
	cd ..
done
