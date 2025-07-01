process QC_FASTCAT_BAMSTATS {
    publishDir "${params.output_dir}/QC/FASTCAT_BAMSTATS", mode: 'copy', overwrite: true
    container 'ontresearch/wf-common:latest' // TODO 

    input:
    path basecalled_fastq
    tuple path(aligned_bam), path(bai)

    output:
    path "fastcat_stats.txt", emit: fastcat_output
    path "fastcat_hist/", emit: fastcat_hist
    path "bamstat_hist/", emit: bamstat_hist

    script:
    """
    fastcat -s sample_name --histograms fastcat_hist/ --file fastcat_stats.txt ${basecalled_fastq} > /dev/null
    bamstats -s sample_name --histograms bamstat_hist/ ${aligned_bam} > /dev/null
    """
}
