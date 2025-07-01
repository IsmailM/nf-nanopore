process QC_FASTP_LONG {
    publishDir "${params.output_dir}/QC/FASTP_LONG", mode: 'copy', overwrite: true
    container 'quay.io/biocontainers/fastplong:0.3.0--h224cc79_0'

    input:
    path basecalled_fastq

    output:
    path "fastp_report.html", emit: fastp_report
    path "fastp_report.json", emit: fastp_json

    script:
    """
    fastplong -i ${basecalled_fastq} -o fastp_report.fastq.gz \\
          --html fastp_report.html \\
          --json fastp_report.json \\
          --thread ${task.cpus}
    """
}
