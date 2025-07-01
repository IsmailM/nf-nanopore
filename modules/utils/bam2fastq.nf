process BASECALLED_FASTQ {
    publishDir "${params.output_dir}/BASECALLED_FASTQ", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'

    input:
    path basecalled_bam

    output:
    path "calls.fastq.gz", emit: basecalled_fastq

    script:
    """
    samtools fastq ${basecalled_bam} | gzip > calls.fastq.gz
    """
}

