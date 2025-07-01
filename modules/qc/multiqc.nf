process MULTIQC {
    publishDir "${params.output_dir}/QC/MULTIQC", mode: 'copy', overwrite: true
    container 'multiqc/multiqc:v1.29'
    
    input:
    path fastp_long
    path mosdepth_summary
    path mosdepth_global_dist
    path fastcat_bamstats_report
    path fastcat_hist
    path bamstat_hist
    path toulligqc_report
    path nanoplot_report
    path cramino_report
    path alignment_summary

    output:
    path "multiqc_report.html", emit: multiqc_report

    script:
    """
    multiqc .
    """
}