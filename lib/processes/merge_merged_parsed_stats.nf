process MERGE_MERGED_PARSED_STATS {
    publishDir "${params.output}/Nanostat_parsed_merged/", mode: 'copy'
  input:
    path( stats )
    val merge_parsed_runs_R
  output:
    path( "*.tsv" ), emit: merged_parsed_stats
  script:
  """
    Rscript ${merge_parsed_runs_R} \
    --parsed_files ${stats} \
    --run all_runs \
    --min_read_length ${params.min_read_length} \
    --min_qscore ${params.min_qscore}
  """
} 