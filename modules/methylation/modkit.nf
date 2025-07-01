process MODKIT {
    publishDir "${params.output_dir}/MODKIT", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/ont-modkit:0.5.0--hcdda2d0_0'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(ref), path(ref_idx)

    output:
    path "pileup.bed", emit: modkit_pileup
    path "modkit_summary.txt", emit: modkit_summary
    path "entropy.bed", emit: modkit_entropy

    script:
    """
    modkit pileup --ref ${ref} --preset traditional ${aligned_bam} pileup.bed
    modkit summary ${aligned_bam} > modkit_summary.txt
    modkit entropy --in-bam ${aligned_bam} --ref ${ref} --cpg --out-bed entropy.bed
    """
}
