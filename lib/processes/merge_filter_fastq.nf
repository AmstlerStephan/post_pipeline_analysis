process MERGE_FILTER_FASTQ {
    input:
        tuple val( run ), val( barcode ), path( barcode_fastq_dir ) 
    output:
        tuple val( "${run}" ), val( "${barcode}" ), path( "*fastq"), emit: merged_fastq
    script:
    """
        catfishq --min-length ${params.min_read_length} \
        --min-qscore ${params.min_qscore} \
        --output ${run}_${barcode}_${params.min_read_length}_${params.min_qscore}.fastq \
        --recursive \
        ${barcode_fastq_dir}
    """
}