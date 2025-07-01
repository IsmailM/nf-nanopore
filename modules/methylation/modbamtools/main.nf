process MODBAMTOOLS {
    publishDir "${params.output_dir}/MODBAMTOOLS", mode: 'copy', overwrite: true
    container 'ghcr.io/ismailm/modbamtools:v0.0.3'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(ref), path(ref_idx)
    tuple path(modbamtools_gencode), path(modbamtools_gencode_tbi)
    path(modbamtools_locations_bed)

    output:
    path "promoters_calcMeth.bed", emit: modbamtools_pileup
    path "promoters_calcMeth_hap.bed", emit: modbamtools_summary
    path "genes_clustered.bed", emit: modbamtools_entropy
    path "sample_name1.html", emit: modbamtools_html

    script:
    """
    # Regional methylation calculation
    modbamtools calcMeth --bed ${modbamtools_locations_bed} \
        --threads ${task.cpus} \
        --out promoters_calcMeth.bed \
        ${aligned_bam}

    # Haplotype stats
    #  output stats for each haplotype based on HP tag.
    modbamtools calcMeth --bed ${modbamtools_locations_bed} \
        --threads ${task.cpus} \
        --hap \
        --out promoters_calcMeth_hap.bed \
        ${aligned_bam}

    # Clustering (HDBSCAN)
    modbamtools cluster --bed ${modbamtools_locations_bed} \
        --threads ${task.cpus} \
        --out genes_clustered.bed \
        ${aligned_bam}
    
    modbamtools plot --batch ${modbamtools_locations_bed} \
        --gtf ${modbamtools_gencode} \
        --out . \
        --hap \
        --prefix sample_name1 \
        --samples sample_name1\
        --track-titles Genes \
        ${aligned_bam}
    """
}
