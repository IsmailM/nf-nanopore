process SNIFFLES_CALLER {
    publishDir "${params.output_dir}/VARIANTS/SNIFFLES", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/sniffles:2.6.2--pyhdfd78af_0'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(ref), path(ref_idx)

    output:
    path "sniffles.vcf", emit: sniffles_vcf

    script:
    """
    sniffles --input ${aligned_bam} --vcf sniffles.vcf --reference ${ref} --mosaic
    """
}
