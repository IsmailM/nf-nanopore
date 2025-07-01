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
  * MultiQC
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

wget -O https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gtf.gz
wget -O https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/gencode.v38.annotation.gtf.gz
wget -O https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/gencode.v38.annotation.gtf.gz.tbi
wget -O https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/genes.bed
wget -o https://raw.githubusercontent.com/IsmailM/nf-nanopore/refs/heads/main/test_files/example.config

```

2. Install Nextflow (follow instructions [here](https://www.nextflow.io/docs/latest/install.html)) and docker.

```bash
curl -s https://get.nextflow.io | bash
```

3. Start the pipeline:

```bash 
nextflow run IsmailM/nf-nanopore --output_dir output -c data/example.config \
  --ref ./data/chr22_meth_example/humangenome.fa \
  --fast5_dir ./data/chr22_meth_example/fast5_files
```

This should take around 15-20 mins with a machine with a GPU.

### Release a new Docker build

The pipeline uses docker images on Github Docker Registry. If you make any changes to the underlying files including in the dockerfile, please push them to Dockerhub:

1. Login using a token with access to Github Packages. See [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) for more info.

```bash
export CR_PAT=YOUR_TOKEN

echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

2. Build docker image and upload to Github Packages

```bash
VERSION=v0.0.1
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


