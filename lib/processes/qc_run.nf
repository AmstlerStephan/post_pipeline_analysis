process QC_RUN {
    publishDir "${params.output}/Nanostat/${run}/${barcode}/", mode: 'copy'
  input:
    tuple val( run ), val( barcode ), path( fastq_file )
  output:
    tuple val( "${run}" ), val( "${barcode}" ), path( "${stats}" ), emit: stats
  script:
  stats = "${fastq_file.simpleName}.tsv"
  """
    NanoStat --fastq ${fastq_file} --outdir . -n ${stats} -t ${params.threads}
  """
}