#!/bin/bash
# This is a bash script to test the pipeline before converting it to a Nextflow pipeline.

BASE_DIR="/mnt/scratch2/imoghul/hurdle"
DATA_DIR="${BASE_DIR}/data/chr22_meth_example"
FAST5_DIR="${DATA_DIR}/fast5_files"
MODEL="fast" # "hac,5mCG_5hmCG"

alias dorado="$BASE_DIR/src/dorado-0.9.6-linux-x64/bin/dorado"

## TEST DATA

# https://github.com/nanopore-wgs-consortium/NA12878/blob/master/Genome.md
#  R9.4 chemistry

# Downloading the test Fast5 data
# cd "${DATA_DIR}" || exit 1
# wget -O f5c_na12878_test.tgz "https://f5c.page.link/f5c_na12878_test"
# tar -xvf f5c_na12878_test.tgz

# Looking at the data:
# cd "${DATA_DIR}"/chr22_meth_example || exit 1
# ls -lh

## Convert to pod5 format
# mise use python
# pip install pod5
# pip install ont-fast5-api
# # convert single-read Fast5 files to multi-file Fast5 format
# single_to_multi_fast5 --input_path ${FAST5_DIR} --save_path ${DATA_DIR}/multi_fast5 --threads 40 --recursive
# pod5 convert fast5 ${DATA_DIR}/multi_fast5/*fast5 --output ${DATA_DIR}/reads.pod5


# Download the Model 
dorado download --model 'dna_r9.4.1_e8_hac@v3.3'

## BASECALLING WITH DORADO
cd "${BASE_DIR}" || exit 1
cd run || exit 1

# Basecalling with Dorado using the test Fast5 data
dorado basecaller ./dna_r9.4.1_e8_hac@v3.3 ${DATA_DIR}/multi_fast5 --modified-bases 5mCG_5hmCG > calls/calls.bam
# can add the --reference option to align to a reference genome ls
# --reference ${DATA_DIR}/humangenome.fa 

dorado aligner "${DATA_DIR}/humangenome.fa" calls/calls.bam --emit-summary --output-dir aligned/

# CLAIR3
MODEL_NAME="r941_prom_sup_g5014"
docker run -it \
  -v ${DATA_DIR}:${DATA_DIR} -v ${PWD}:${PWD} \
  hkubal/clair3:latest /opt/bin/run_clair3.sh \
  --bam_fn=${PWD}/aligned/calls.bam \
  --ref_fn=${DATA_DIR}/humangenome.fa \
  --threads=100 \
  --platform="ont" \
  --model_path="/opt/models/${MODEL_NAME}" \
  --output=${PWD}/variant

# SNIFFLES 

sniffles -i ${PWD}/aligned/calls.bam -v  ${PWD}/variants/structural_variants.vcf
python3 -m sniffles2_plot -i ${PWD}/variants/structural_variants.vcf -o qc/sniffles/

# SNPEFF
# https://github.com/aws-samples/aws-batch-genomics/blob/master/tools/snpeff/docker/Dockerfile
docker run -it --rm \
  -v ${PWD}:${PWD} \
  -w ${PWD} \
  -u $(id -u):$(id -g) \
  staphb/snpeff:latest \
  bash -c "snpEff GRCh38.mane.1.2.ensembl variant/merge_output.vcf.gz > variant/merge_output.ann.vcf"
# GRCh38.mane.1.2.refseq

## USE VEP 
docker run -it --rm \
  -v ${PWD}:${PWD} \
  -w ${PWD} \
  -u $(id -u):$(id -g) \
  ensemblorg/ensembl-vep:latest \
  bash -c "vep --fork 100 -i variant/merge_output.vcf.gz --database --dir_cache ./vep-cache --assembly GRCh38 --output_file variant/merge_output.vep.vcf"


# phasing
whatshap phase -o variant/phased.vcf --reference ${DATA_DIR}/humangenome.fa variant/merge_output.vcf.gz aligned/calls.bam

modkit pileup aligned/calls.bam mods/sample1.bed \
  --ref ${DATA_DIR}/humangenome.fa \
  --preset traditional

modkit summary aligned/calls.bam




### QC
# Generate a FASTQ file from the basecalled data
samtools fastq calls/calls.bam | gzip > calls/calls.fastq.gz

# https://github.com/OpenGene/fastplong
fastplong -i calls/calls.fastq.gz -o qc/fastp/calls.out.fq


# https://github.com/wdecoster/cramino
cramino aligned/aligned.bam --phased --hist qc/cramino/hist.txt 
# https://github.com/wdecoster/nanoplot/
NanoPlot -t 2 --fastq calls/calls.fastq.gz --maxlength 40000 --plots dot --legacy hex

#https://github.com/GenomiqueENS/toulligQC
# https://github.com/wdecoster/chopper



# https://github.com/brentp/mosdepth
# mosdepth -n --fast-mode --no-per-base ${DATA_DIR}/qc/mosdepth/sample ${DATA_DIR}/aligned/aligned.bam

# https://github.com/epi2me-labs/fastcat
fastcat -s sample_name --histograms qc/fastcat/hist/ --file qc/fastcat/sample.txt calls/calls.fastq.gz > qc/fastcat/calls.fastq
bamstats -s sample_name --histograms qc/bamstats/hist/ aligned/aligned.bam

samtools stats -c 1000 aligned/aligned.bam > qc/samtools/stats.txt
