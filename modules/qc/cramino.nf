process QC_CRAMINO {
    publishDir "${params.output_dir}/QC/CRAMINO", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/cramino:1.1.0--h3dc2dae_0'

    input:
    tuple path(aligned_bam), path(bai)

    output:
    path "cramino_hist.txt", emit: cramino_hist

    script:
    """
    cramino ${aligned_bam} --phased --hist cramino_hist.txt
    """
}
