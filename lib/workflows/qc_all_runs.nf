nextflow.enable.dsl = 2

requiredParams = [
    'input'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

merge_parsed_run = file( "${projectDir}/bin/merge_parsed_run.R", checkIfExists: true)

// STAGE CHANNELS
if (params.all_runs) {
    barcodes = Channel.fromPath("${params.input}/run*/fastq_pass/barcode*", type: 'dir') 
}else{
    barcodes = Channel.fromPath("${params.input}/fastq_pass/barcode*", type: 'dir') 
}

barcodes = barcodes
.map { 
    barcode_path -> 
        run = (barcode_path =~ /run\d*_*V*\d*/)[0]
        barcode = barcode_path.baseName
        tuple( run, barcode, barcode_path ) 
}

sample_sheets = [:]
Channel.fromPath("${params.input}/**${params.sample_sheet}", type: 'file')
.map { 
    sample_sheet_path ->
        run = ( sample_sheet_path =~ /run\d*_*V*\d*/)[0]
        sample_sheets.put("$run", sample_sheet_path)
}

run_metrics = Channel.fromPath("${params.input}/**.md", type: 'file')
.map { 
    run_metrics_path ->
        run = ( run_metrics_path =~ /run\d*_*V*\d*/)[0]
        tuple( run, run_metrics_path)
}
 

include { NANOPORE_QC } from './nanopore_qc.nf'

include {MERGE_MERGED_PARSED_STATS} from '../processes/merge_merged_parsed_stats.nf'

include { get_run_dirs } from '../functions/get_run_dirs.nf' params(input: params.input)

runs = get_run_dirs(params.input)

workflow QC_ALL_RUNS {
    NANOPORE_QC( barcodes, sample_sheets, run_metrics )

    if( params.merge_all ){

        MERGE_MERGED_PARSED_STATS( NANOPORE_QC.out.merged_tsv, merge_parsed_run)
    }
}