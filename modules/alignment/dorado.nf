process DORADO_ALIGNER {
    publishDir "${params.output_dir}/DORADO_ALIGNER", mode: 'copy', overwrite: true
    container 'nanoporetech/dorado:latest'

    input:
    path basecalled_bam
    tuple path(ref), path(ref_idx)

    output:
    tuple path("aligned_output/calls.bam"),
          path("aligned_output/calls.bam.bai"), emit: aligned_bam
    path "aligned_output/alignment_summary.txt", emit: alignment_summary

    script:
    """
    dorado aligner ${ref} ${basecalled_bam} --emit-summary --output-dir aligned_output
    """
}
