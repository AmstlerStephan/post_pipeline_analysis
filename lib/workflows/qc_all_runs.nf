nextflow.enable.dsl = 2

requiredParams = [
    'input', 'fastq_dir'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

merge_parsed_run = file( "${projectDir}/bin/merge_parsed_run.R", checkIfExists: true)

print params.fastq_dir

// STAGE CHANNELS
if (params.all_runs) {
    barcodes_ch = Channel.fromPath("${params.input}/run*/${params.fastq_dir}/barcode*", type: 'dir', maxDepth: '1')
    .view()
    sample_sheets_ch = Channel.fromPath("${params.input}/run*/lib/${params.sample_sheet}", type: 'file')
    run_metrics_ch = Channel.fromPath("${params.input}/run*/report*.md", type: 'file')
}else{
    barcodes_ch = Channel.fromPath("${params.input}/${params.fastq_dir}/barcode*", type: 'dir') 
    sample_sheets_ch = Channel.fromPath("${params.input}/lib/${params.sample_sheet}", type: 'file')
    run_metrics_ch = Channel.fromPath("${params.input}/report*.md", type: 'file')
}
barcode_sizes = [:] 
sample_sheets = [:]

barcodes_ch
.map { 
    barcode_path -> 
        run = (barcode_path =~ /run\d*_*V*\d*/)[0]
        barcode = barcode_path.baseName
        tuple( run, barcode, barcode_path ) 
}
.set{ barcodes }

sample_sheets_ch
.map { 
    sample_sheet_path ->
        run = ( sample_sheet_path =~ /run\d*_*V*\d*/)[0]
        sample_sheets.put("$run", sample_sheet_path)
}

run_metrics_ch
.map { 
    run_metrics_path ->
        run = ( run_metrics_path =~ /run\d*_*V*\d*/)[0]
        tuple( run, run_metrics_path)
}
.set{ run_metrics }

include { NANOPORE_QC } from './nanopore_qc.nf'
include {MERGE_MERGED_PARSED_STATS} from '../processes/merge_merged_parsed_stats.nf'

workflow QC_ALL_RUNS {
    NANOPORE_QC( barcodes, sample_sheets, run_metrics, barcode_sizes )

    if( params.merge_all ){

        NANOPORE_QC.out.merged_tsv
        .collect()
        .set{ collected_tsv_files }

        MERGE_MERGED_PARSED_STATS( collected_tsv_files, merge_parsed_run)
    }
}