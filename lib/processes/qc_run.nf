process QC_RUN {
  input:
    tuple val( run ), val( barcode ), path( fastq_file )
  output:
    tuple val( "${run}" ), val( "${barcode}" ), path( "*.tsv"), emit: stats
  script:
  """
    NanoStat --fastq $fastq --outdir $outdir/stats/$2 -n $(basename $fastq .fastq.gz) -t 6 --tsv
  """
}