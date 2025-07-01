process MODBAMTOOLS {
    publishDir "${params.output_dir}/MODBAMTOOLS", mode: 'copy', overwrite: true
    container 'ghcr.io/ismailm/modbamtools:v0.0.1'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(ref), path(ref_idx)

    output:
    path "promoters_calcMeth.bed", emit: modbamtools_pileup
    path "promoters_calcMeth_hap.bed", emit: modbamtools_summary
    path "genes_clustered.bed", emit: modbamtools_entropy
    path "sample_name1.html", emit: modbamtools_html

    script:
    """

    # Regional methylation calculation
    modbamtools calcMeth --bed promoters.bed \
        --threads ${task.cpus} \
        --out promoters_calcMeth.bed \
        ${aligned_bam}

    # Haplotype stats
    #  output stats for each haplotype based on HP tag.
    modbamtools calcMeth --bed promoters.bed \
        --threads ${task.cpus} \
        --hap \
        --out promoters_calcMeth_hap.bed \
        ${aligned_bam}

    # Clustering (HDBSCAN)
    modbamtools cluster --bed genes.bed \
        --threads ${task.cpus} \
        --out genes_clustered.bed \
        ${aligned_bam}
        
    modbamtools plot --batch genes.bed \
        --gtf gencode.v38.annotation.sorted.gtf.gz \
        --out . \
        --hap \
        --threads 100 \
        --prefix sample_name1 \
        --samples sample_name1\
        --track-titles Genes \    
        ${aligned_bam}
    """
}
