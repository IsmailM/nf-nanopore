process QC_NANOPLOT {
    publishDir "${params.output_dir}/QC/NANOPLOT", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/nanoplot:1.44.1--pyhdfd78af_0'

    input:
    path basecalled_fastq

    output:
    path "nanoplot_report", emit: nanoplot_report

    script:
    """
    NanoPlot -t ${task.cpus} --fastq ${basecalled_fastq} --maxlength 40000 --plots dot --legacy hex --outdir nanoplot_report
    """
}
