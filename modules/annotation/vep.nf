
process ANNOTATION_VEP {
    publishDir "${params.output_dir}/ANNOTATION/VEP", mode: 'copy', overwrite: true
    container 'ensemblorg/ensembl-vep:latest'

    input:
    tuple path(variants_vcf), path(variants_vcf_tbi)
    
    output:
    path "annotated_variants.vep.vcf", emit: annotated_variants_vep_vcf

    script:
    """
    # TODO setup VEP CACHE ONCE.
    vep -i ${variants_vcf} \\
    --fork ${task.cpus} \\
    --database --dir_cache ./vep-cache \\
    --assembly GRCh38 \\
    --force_overwrite --vcf --output_file annotated_variants.vep.vcf
    """
}
