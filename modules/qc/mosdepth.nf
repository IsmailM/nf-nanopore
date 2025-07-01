process QC_MOSDEPTH {
    publishDir "${params.output_dir}/QC/MOSDEPTH", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/mosdepth:0.3.10--h4e814b3_1'

    input:
    tuple path(aligned_bam), path(bai)

    output:
    path "sample_name.mosdepth.global.dist.txt", emit: mosdepth_global_dist
    path "sample_name.mosdepth.summary.txt", emit: mosdepth_summary

    script:
    """
    mosdepth --threads ${task.cpus} --fast-mode --no-per-base sample_name ${aligned_bam}
    """
}
