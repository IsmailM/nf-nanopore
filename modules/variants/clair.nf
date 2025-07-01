process CLAIR_CALLER {
    publishDir "${params.output_dir}/VARIANTS/CLAIR", mode: 'copy', overwrite: true
    container 'hkubal/clair3:latest'

    input:
    tuple path(aligned_bam), path(bai)
    tuple path(ref), path(ref_idx)

    output:
    tuple path("variant/merge_output.vcf.gz"), path("variant/merge_output.vcf.gz.tbi"), emit: variants_vcf

    script:
    """
    /opt/bin/run_clair3.sh \\
        --bam_fn=${aligned_bam} \\
        --ref_fn=${ref} \\
        --threads=100 \\
        --platform="ont" \\
        --model_path="/opt/models/${params.clair3?.model}" \\
        --output=variant
    """
}
