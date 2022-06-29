'''
RUNNING ENV: py36
snakemake -j 999 --cluster-config cluster.json --cluster 'bsub -n {cluster.threads} -R "rusage[mem={cluster.memory}]" -W {cluster.walltime}'
'''

from glob import glob
import json


# !!!!!!!!! Since the output function globs all the results from the folders so there is no need for a input json
sample_dir = '/gpfs/home/bc3125/scratch/irep_HCT/data/out_01/SampleNameReplace'
# FILE = json.load(open('../input/all_nutrition_growth.json'))
# sample_names = FILE.keys()
# sample_names = [i+'__concat' for i in sample_names]

sample_names = ['SampleNameReplace']
#==================================================================================================================================================
localrules: ret 

# for the samples that have multiple R1 and R2 in the folder:
rule bowtie2_index_samplebin:
    input:
        '{sample_dir}/binning_das_tool/{sample_names}/DAS_tool_bins/{samplebin}.fa'
    output:
        touch('{sample_dir}/bowtie_dastool___{sample_names}___{samplebin}___index.done')
    params:
        '{sample_dir}/binning_das_tool/{sample_names}/DAS_tool_bins/{samplebin}.fa'
    shell:
        'bowtie2-build {input[0]} {params[0]}'


# mapping to one of the dereplicated genomes to produce sam file

rule bowtie2_align_samplebin:
    input:
        r1='{sample_dir}/preprocessing/01_processing/05_sync/{sample_names}_1.fq.gz',
        r2='{sample_dir}/preprocessing/01_processing/05_sync/{sample_names}_2.fq.gz',
        spp='{sample_dir}/binning_das_tool/{sample_names}/DAS_tool_bins/{samplebin}.fa'
    output:
        '{sample_dir}/{sample_names}__dastools_align__{samplebin}.sam'
    threads:
        8
    shell:
        'bowtie2 -q -x {input.spp}  --reorder  --no-unal  -p {threads} -1 {input.r1} -2 {input.r2} -S {output}'

# now do the irep methods

rule irep_run:
    input:
        spp_fa='{sample_dir}/binning_das_tool/{sample_names}/DAS_tool_bins/{samplebin}.fa',
        reordered_sam='{sample_dir}/{sample_names}__dastools_align__{samplebin}.sam'
    output:
        touch('{sample_dir}/{sample_names}__{samplebin}_irep_run.done')
    params:
        prefix='{sample_dir}/{sample_names}__{samplebin}_irep_dastool'
    threads:
        16
    shell:
        'iRep -f {input.spp_fa} -s {input.reordered_sam}   -o {params.prefix}  -t {threads}'


# for calculating the coverage

rule samtools_to_bam:
    input:
        '{sample_dir}/{sample_names}__dastools_align__{samplebin}.sam'
    output:
        '{sample_dir}/{sample_names}__dastools_align__{samplebin}.bam'
    shell:
        'samtools view -S -b {input} | samtools sort -m 3G - -o {output}'

rule samtools_coverate:
    input:
        '{sample_dir}/{sample_names}__dastools_align__{samplebin}.bam'
    output:
        '{sample_dir}/{sample_names}__dastools_align__{samplebin}_coverage.txt'
    shell:
        'samtools coverage {input} -o {output}'

# drep for every sample to remove the redundant bins


rule derep_for_each_sample:
    input:
        '{sample_dir}/binning_das_tool/{sample_names}/DAS_tool_bins'
    output:
        touch('{sample_dir}/{sample_names}_drep.done')
    params:
        directory='{sample_dir}/drep_each_sample/{sample_names}'
    threads:
        16
    shell:
        '''
        files=$(ls {input}/*.fa)
        dRep dereplicate {params.directory} -p {threads} -g $files -comp 50 -con 15
        '''


def get_irep_res():
  fa_files = glob(f'{sample_dir}/binning_das_tool/*/DAS_tool_bins/*.fa')
  res = []
  for f in fa_files:
    sample_bin = f.split('/')[-1][0:-len('.fa')]
    sample_name = f.split('/')[-3]
    res.append(f'{sample_dir}/{sample_name}__{sample_bin}_irep_run.done')
  return res

def get_bin_dex():
  fa_files = glob(f'{sample_dir}/binning_das_tool/*/DAS_tool_bins/*.fa')
  res = []
  for f in fa_files:
    sample_bin = f.split('/')[-1][0:-len('.fa')]
    sample_name = f.split('/')[-3]
    res.append(f'{sample_dir}/bowtie_dastool___{sample_name}___{sample_bin}___index.done')
  return res

def get_bin_coverage():
  fa_files = glob(f'{sample_dir}/binning_das_tool/*/DAS_tool_bins/*.fa')
  res = []
  for f in fa_files:
    sample_bin = f.split('/')[-1][0:-len('.fa')]
    sample_name = f.split('/')[-3]
    res.append(f'{sample_dir}/{sample_name}__dastools_align__{sample_bin}_coverage.txt')
  return res

rule cov:
    input:
        get_bin_coverage()

rule res:
    input:
        get_bin_dex()

rule ret:
    input:
      get_irep_res()

fns = expand('{sample_dir}/{sample_names}_drep.done', sample_dir = sample_dir, sample_names = sample_names)

rule final:
    input: fns
