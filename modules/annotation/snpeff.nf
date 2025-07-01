process ANNOTATION_SNPEFF {
    publishDir "${params.output_dir}/ANNOTATION/SNPEFF", mode: 'copy', overwrite: true
    container 'staphb/snpeff:latest'

    input:
    tuple path(variants_vcf), path(variants_vcf_tbi)

    output:
    path "annotated_variants.snpeff.vcf", emit: annotated_variants_vcf

    script:
    """
    snpEff ${params.SNPEFF.ref} ${variants_vcf} > annotated_variants.snpeff.vcf
    """
}
