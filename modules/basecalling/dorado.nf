process DORADO_BASECALLER {
     publishDir "${params.output_dir}/DORADO_BASECALLER", mode: 'copy', overwrite: true
    // For FAST5 input use dorado 0.9.5, otherwise the latest version of Dorado
    container params.using_fast5 ? 'nanoporetech/dorado:sha268dcb4cd02093e75cdc58821f8b93719c4255ed' : 'nanoporetech/dorado:latest'
    containerOptions {
        workflow.containerEngine == 'docker' ? '--gpus all' : 
            workflow.containerEngine == 'singularity' ? '--nv' : 
                workflow.containerEngine == 'apptainer' ? '--nv' : ''
    }
  
    accelerator 1 // For AWS Batch - to use a GPU instance

    input:
    path pod5_or_fast5_dir

    output:
    path "calls.bam", emit: basecalled_bam

    script:
    // Model selection logic: file > download_key > name
    def model_to_use = ""
    def need_download = false

    if (params.dorado_model_file) {
        model_to_use = params.dorado.model.file
    } else if (params.dorado_model_download_key) {
        model_to_use = params.dorado.model.download_key
        need_download = true
    } else if (params.dorado_model_name) {
        model_to_use = params.dorado.model.name
    } else {
        model_to_use = "hac,5mCG_5hmCG"
    }
    
    """
    # Set model path based on type
    if [ "${need_download}" = "true" ]; then
        dorado download --model ${model_to_use}
    fi

    # Run basecalling
    echo "Running basecalling with model: ${model_to_use}"
    dorado basecaller \\
        ${model_to_use} \\
        ${pod5_or_fast5_dir} \\
        ${params.dorado_args ?: ''} \\
        > calls.bam
    echo "Basecalling completed, output written to calls.bam"
    """
}

