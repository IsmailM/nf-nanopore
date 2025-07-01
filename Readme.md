# NF-nextflow.

This is a pipeline for Nanopore Sequencing data that runs the following tools:

* BaseCalling 
  * [Dorado](https://github.com/nanoporetech/dorado)
* Alignment
  * [Minimap2](https://github.com/lh3/minimap2) (via `dorado aligner`)
* Variant Calling
  * [Clair3](https://github.com/HKU-BAL/Clair3) 
  * [Sniffles](https://github.com/fritzsedlazeck/Sniffles)
* Variant Annotation
  * [SnpEff - Not fully implemented ](https://pcingola.github.io/SnpEff/)
  * [VEP](https://www.ensembl.org/info/docs/tools/vep/index.html)
  * [whatshap](https://whatshap.readthedocs.io/en/latest/)
* Modification Calling 
  * [ModKit](https://github.com/nanoporetech/modkit)
  * [Modbamtools](https://github.com/rrazaghi/modbamtools)
* QC
  * [FastpLong](https://github.com/OpenGene/fastplong)
  * [ToulligQC](https://github.com/GenomiqueENS/toulligQC)
  * [Nanoplot](https://github.com/wdecoster/nanoplot)
  * [Mosdepth](https://github.com/brentp/mosdepth)
  * [FastCat](https://github.com/epi2me-labs/fastcat)
  * [Cramino](https://github.com/wdecoster/cramino)
  * [Chopper](https://github.com/wdecoster/chopper)
  * [sniffles Plotter](https://github.com/farhangus/Sniffles2_plot)


## Running the pipeline:

1. Download test data 

> Note that you will need to have samtools (tabix and bgzip) installed to run the below.

```bash
mkdir data
cd data || exit 1
wget -O f5c_na12878_test.tgz "https://f5c.page.link/f5c_na12878_test"
tar -xvf f5c_na12878_test.tgz
rm f5c_na12878_test.tgz

# wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gtf.gz
# wget https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/genes.bed

cd .. || exit 1
wget https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/example.config
```

2. Install Nextflow (follow instructions [here](https://www.nextflow.io/docs/latest/install.html)) and docker.

```bash
curl -s https://get.nextflow.io | bash
```

3. Start the pipeline:

```bash 
nextflow run IsmailM/nf-nanopore -latest --output_dir output -c example.config \
  --ref ./data/chr22_meth_example/humangenome.fa \
  --fast5_dir ./data/chr22_meth_example/fast5_files
```

This should take around 15-20 mins with a machine with a GPU.

## Development

During development, it is easier to run nextflow as follows:

1. Clone the repo:

```bash
git clone https://github.com/IsmailM/nf-nanopore
```

2. Call Nextflow directly

```bash
nextflow run main.nf -resume -with-tower --output_dir out -c nextflow.config \
  --ref ../data/chr22_meth_example/humangenome.fa \
  --fast5_dir ../data/chr22_meth_example/fast5_files \
  --dorado_model_download_key dna_r9.4.1_e8_hac@v3.3 \
  --modbamtools_locations_bed ../data/genes.bed \
  --modbamtools_gencode ../data/gencode.v38.annotation.gtf.gz
```

> [!NOTE]  
> Note that the above command resumes where possible and also attempts to use sequera platform for monitoring.
> This requires the TOWER_ACCESS_TOKEN env variable to 

### Release a new Docker build

The pipeline uses docker images on Github Docker Registry. If you make any changes to the underlying files including in the dockerfile, please push them to Dockerhub:

1. Login using a token with access to Github Packages. See [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) for more info.

```bash
export CR_PAT=YOUR_TOKEN

echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

2. Build docker image and upload to Github Packages

```bash
VERSION=v0.0.3
IMAGES=(
  "ont-fast5-api:modules/utils/ont-fast5-api"
  "sniffles_plotter:modules/qc/sniffles_plot"
  "modbamtools:modules/methylation/modbamtools"
)

for img in "${IMAGES[@]}"; do
    d_label=${img%%:*}
    d_src_path=${img#*:}
    docker build -t ${d_label} ${d_src_path}
    docker tag ${d_label} ghcr.io/ismailm/${d_label}:${VERSION}
    docker tag ${d_label} ghcr.io/ismailm/${d_label}:latest
    docker push ghcr.io/ismailm/${d_label}:${VERSION}
    docker push ghcr.io/ismailm/${d_label}:latest
done
```

## Further Work:

1. Take into account QC output before alignment (e.g. FASTP filtered FASTQs)
2. Support Multiple Samples. (CSV input)
3. split processes by chrom where possible
4. Convert Fast5 to Pod5 and always use the latest version of dorado
5. Include `aws` in each container (in prep for cloud)
6. Support basecalling resumability (`--resume-from incomplete.bam`) - to have better resumability (maybe mount directory - and then resume from there)
7. Local Docker Images (docker security scans show potential issues for some publicly used files)
