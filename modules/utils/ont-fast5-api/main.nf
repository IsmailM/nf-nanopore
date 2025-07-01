process SINGLE_TO_MULTI_FAST5 {
    publishDir "${params.output_dir}/FAST5/PROCESSED_FAST5", mode: 'copy', overwrite: true
    container 'ghcr.io/ismailm/ont-fast5-api:v0.0.3'

    input:
    path fast5_dir

    output:
    path "processed_fast5/", emit: processed_fast5

    script:
    """
    /app/convert_single_to_multi_fast5.sh $fast5_dir processed_fast5 $task.cpus
    # TODO - to implement
    # /app/multi_fast5_to_pod5.sh processed_fast5 pod5 
    """
}