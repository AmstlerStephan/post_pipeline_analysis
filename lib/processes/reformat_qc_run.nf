process REFORMAT_QC_RUN {
    publishDir "${params.output}/Nanostat_parsed/${run}/${barcode}/", mode: 'copy'
  input:
    tuple val( run ), val( barcode ), path( stats )
    val qc_run_R
  output:
    tuple val( "${run}" ), val( "${barcode}" ), path( "*.tsv" ), emit: parsed_stats
  script:
  """
    Rscript ${qc_run_R} --nanostat_tsv ${stats} 
  """
} 