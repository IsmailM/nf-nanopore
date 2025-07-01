process INDEX_REFERENCE {
    publishDir "${params.output_dir}/REFERENCE", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'

    input:
    path "ref.fa"

    output:
    tuple path("ref.fa"), path("ref.fa.fai"), emit: ref

    script:
    """
    samtools faidx ref.fa
    """
}
