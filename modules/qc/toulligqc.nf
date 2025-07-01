process QC_TOUILLIGQC {
    publishDir "${params.output_dir}/QC/TOUILLIGQC", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/toulligqc:2.7.1--pyhdfd78af_0'

    input:
    path basecalled_fastq
    tuple path(aligned_bam), path(bai)

    output:
    path "toulligqc_report.html", emit: toulligqc_report

    script:
    """
    toulligqc --report-name sample_name \\
        --bam ${aligned_bam} \\
        --html-report-path toulligqc_report.html
    """
}
