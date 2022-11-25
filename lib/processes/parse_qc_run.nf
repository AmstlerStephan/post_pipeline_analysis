process PARSE_QC_RUN {
    publishDir "${params.output}/Nanostat_parsed/${run}/${barcode}/", mode: 'copy'
  input:
    tuple val( run ), val( barcode ), path( stats ), path( sample_sheet )
    val parse_stats_R
  output:
    tuple val( "${run}" ), path( "*.tsv" ), emit: parsed_stats
  script:
  """
    Rscript ${parse_stats_R} \
    --nanostat_tsv ${stats} \
    --sample_sheet ${sample_sheet} \
    --run ${run} \
    --barcode ${barcode} \
    --min_read_length ${params.min_read_length} \
    --min_qscore ${params.min_qscore}
  """
} 