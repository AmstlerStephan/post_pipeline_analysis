process MERGE_PARSED_STATS {
    publishDir "${params.output}/Nanostat_parsed_merged/${run}", mode: 'copy'
  input:
    tuple val( run ), path( stats )
    val merge_parsed_run_R
  output:
    tuple val( "${run}" ), path( "*.tsv" ), emit: merged_parsed_stats
  script:
  """
    Rscript ${merge_parsed_run_R} --parsed_files ${stats}
  """
} 