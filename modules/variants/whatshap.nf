process PHASING {
    publishDir "${params.output_dir}/VARIANTS/PHASING", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/whatshap:2.8--py39h2de1943_0'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(variants_vcf), path(variants_vcf_tbi)
    tuple path(ref), path(ref_idx)

    output:
    path "phased.bam", emit: phased_bam

    script:
    """
    whatshap phase -o phased.bam --reference ${ref} ${variants_vcf} ${aligned_bam}
    """
}
