nextflow.enable.dsl = 2

requiredParams = [
    'input', 'all_runs'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

// scripts
qc_run = file( "${projectDir}/bin/qc_run.R", checkIfExists: true)
qc_summary = file( "${projectDir}/bin/qc_summary.R", checkIfExists: true)
analyse_run = file( "${projectDir}/bin/analyse_run.R", checkIfExists: true)

// STAGE CHANNELS
if (params.all_runs) {
    barcodes = Channel.fromPath("${params.input}/run*/fastq_pass/barcode*", type: 'dir') 
} else {
    barcodes = Channel.fromPath("${params.input}/fastq_pass/barcode*", type = 'dir')
}
barcodes_tuple = barcodes
.map { barcode_path -> 
        run = (barcode_path =~ /run\d*_*V*\d*/)[0]
        barcode = barcode_path.baseName
        tuple( run, barcode, barcode_path ) }

include {MERGE_FILTER_FASTQ} from '../processes/merge_filter_fastq.nf'

workflow NANOPORE_QC {
    main:

        MERGE_FILTER_FASTQ( barcodes_tuple )
}