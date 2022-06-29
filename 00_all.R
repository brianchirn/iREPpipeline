#!/bin/bash 
#SBATCH --job-name=SampleNameReplace # Job name 
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL) 
#SBATCH --mail-user=brian.chirn@nyulangone.org # Where to send mail 
#SBATCH --ntasks=6 # Run on a single CPU 
#SBATCH --mem=200gb # Job memory request 
#SBATCH --time=24:00:00 # Time limit hrs:min:sec 
#SBATCH --output=/gpfs/home/bc3125/jobreports/slurm_%A_%a.log # Standard output and error log 
#SBATCH -p cpu_short # Specifies location to submit job


# LOAD MODULES
module load singularity/3.9.8

# Preprocessing

snakemake --configfile config_preprocessing.yaml --snakefile /gpfs/home/bc3125/schluterlab/bc3125/projects/bhattlab_workflows/preprocessing/preprocessing.snakefile --jobs 100 --use-singularity --singularity-args '--bind /gpfs'

# Assembly with Megahit

snakemake -s /gpfs/home/bc3125/schluterlab/bc3125/projects/bhattlab_workflows/assembly/assembly.snakefile --configfile config_assembly.yaml --use-singularity --singularity-args '--bind /gpfs'  --jobs 1999 


# Binning
source /gpfs/home/bc3125/miniconda3/etc/profile.d/conda.sh
conda activate bhattv3

export PATH=$PATH:$HOME/tool/MaxBin-2.2.7
export PATH=$PATH:$HOME/tool/DAS_Tool-master/
export PATH=$PATH:$HOME/tool/DAS_Tool-master/src/
export PATH=$PATH:$HOME/tool/DAS_Tool-master/src/Fasta_to_Scaffolds2Bin.sh
export PATH=$PATH:$HOME/tool/MaxBin-2.2.7
export PATH=$PATH:$HOME/tool/usearch
export PATH=$PATH:$HOME/tool/usearch11.0.667_i86linux32
export PATH=$PATH:$PATH/miniconda3/bin

module load bwa

## create binning text
bash create_binning_input.txt.sh  

snakemake --configfile config_binning_manysamp.yaml \
--snakefile ~/projects/bhattlab_workflows/binning/bin_das_tool_manysamp.snakefile \
--cores 30

conda deactivate


# iREP

module load bowtie2

snakemake -j 999 res --rerun-incomplete

snakemake -j 999 ret --rerun-incomplete

mkdir -p irep_sam
mv *.sam irep_sam

mkdir -p irep
mv *_irep_* irep
mv irep/08_get_irep_values.R .

# iREP summary
Rscript 08_get_irep_values.R

# cleanup

FinalFile=./irep/irep_summary.csv 
if test -f "$FinalFile"; then
	rm -r irep_sam
	rm -r ./assembly/02_assembly/02_metaspades/nyujs1/*
	rm -r ./preprocessing/01_processing/01_dedup/*
	rm -r ./preprocessing/01_processing/02_trimmed/*
fi

#rm -r irep_sam
#rm -r /gpfs/home/bc3125/scratch/irep_HCT/test_data/nyujs1/preprocessing/01_processing/
