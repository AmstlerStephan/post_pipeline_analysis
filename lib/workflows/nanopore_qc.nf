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
parse_stats = file( "${projectDir}/bin/qc_run.R", checkIfExists: true)
merge_parsed_run = file( "${projectDir}/bin/merge_parsed_run.R", checkIfExists: true)
qc_summary = file( "${projectDir}/bin/qc_summary.R", checkIfExists: true)

// STAGE CHANNELS
if (params.all_runs) {
    barcodes = Channel.fromPath("${params.input}/run*/fastq_pass/barcode*", type: 'dir') 
} else {
    barcodes = Channel.fromPath("${params.input}/fastq_pass/barcode*", type = 'dir')
}
barcodes_tuple = barcodes
.map { 
    barcode_path -> 
        run = (barcode_path =~ /run\d*_*V*\d*/)[0]
        barcode = barcode_path.baseName
        tuple( run, barcode, barcode_path ) 
}

sample_sheets = [:]
Channel.fromPath("${params.input}/**/${params.sample_sheet}", type: 'file')
.map { 
    sample_sheet_path ->
        run = ( sample_sheet_path =~ /run\d*_*V*\d*/)[0]
        sample_sheets.put("$run", sample_sheet_path)
}

include {MERGE_FILTER_FASTQ} from '../processes/merge_filter_fastq.nf'
include {QC_RUN} from '../processes/qc_run.nf'
include {PARSE_QC_RUN} from '../processes/parse_qc_run.nf'
include {MERGE_PARSED_STATS} from '../processes/merge_parsed_stats.nf'

workflow NANOPORE_QC {
    main:

        MERGE_FILTER_FASTQ( barcodes_tuple )

        merged_filtered_fastq = MERGE_FILTER_FASTQ.out.merged_fastq
            .filter{ run, barcode, fastq_file -> fastq_file.countFastq() > params.min_reads_per_barcode }

        QC_RUN( merged_filtered_fastq )

        stats_added_sample_sheet = QC_RUN.out.stats
        .map{ run, barcode, stats -> 
            sample_sheet = sample_sheets.get("$run")
            tuple( run, barcode, stats, sample_sheet ) }

        PARSE_QC_RUN( stats_added_sample_sheet, parse_stats )
        
        grouped_files_run = PARSE_QC_RUN.out.parsed_stats
            .groupTuple()
            .view()
        
        MERGE_PARSED_STATS( grouped_files_run, merge_parsed_run )

        if(params.merge_all) {
            grouped_files_all = MERGE_PARSED_STATS.out.merged_parsed_stats
            .toList()
            .view()
        }
}