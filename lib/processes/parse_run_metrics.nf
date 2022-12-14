process PARSE_RUN_METRICS {
    publishDir "${params.output}/run_metrics/${run}", mode: 'copy'
  input:
    tuple val( run ), path( metrics )
    path parse_metrics_R
  output:
    path ("*.tsv")
  script:
  """
    Rscript ${parse_metrics_R} \
    --run_metrics ${metrics} \
    --run ${run}
  """
}