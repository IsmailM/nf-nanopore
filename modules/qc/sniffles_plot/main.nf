process SNIFFLES_PLOTTER {
    publishDir "${params.output_dir}/QC/SNIFFLES_PLOTTER", mode: 'copy', overwrite: true
    container 'ghcr.io/ismailm/sniffles_plotter:latest'

    input:
    path(sniffles_vcf)

    output:
    path "sniffles_plot", emit: sniffles_plot

    script:
    """
    python3 -m sniffles2_plot -i ${sniffles_vcf} -o sniffles_plot
    """
}
