process QC_CHOPPER {
    publishDir "${params.output_dir}/QC/CHOPPER", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/chopper:0.10.0--hcdda2d0_0'

    input:
    path basecalled_fastq

    output:
    path "filtered_reads.fastq.gz", emit: chopper_filtered_fastq

    script:
    """
    chopper -q 10 -l 500 -i ${basecalled_fastq} | gzip > filtered_reads.fastq.gz
    """
}
