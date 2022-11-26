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
parse_nanostat = file( "${projectDir}/bin/parse_nanostat.R", checkIfExists: true)
merge_parsed_run = file( "${projectDir}/bin/merge_parsed_run.R", checkIfExists: true)
parse_metrics = file( "${projectDir}/bin/parse_run_metrics.R", checkIfExists: true)

barcodes = Channel.fromPath("${params.input}/fastq_pass/barcode*", type = 'dir')

barcodes_tuple = barcodes
.map { 
    barcode_path -> 
        run = (barcode_path =~ /run\d*_*V*\d*/)[0]
        barcode = barcode_path.baseName
        tuple( run, barcode, barcode_path ) 
}

sample_sheet = file("${params.input}/**/${params.sample_sheet}", checkIfExists: true)

run_metric = Channel.fromPath("${params.input}/**/*.md", checkIfExists: true)
 

include {MERGE_FILTER_FASTQ} from '../processes/merge_filter_fastq.nf'
include {QC_RUN} from '../processes/qc_run.nf'
include {PARSE_QC_RUN} from '../processes/parse_qc_run.nf'
include {MERGE_PARSED_STATS} from '../processes/merge_parsed_stats.nf'
include {MERGE_MERGED_PARSED_STATS} from '../processes/merge_merged_parsed_stats.nf'
include {PARSE_RUN_METRICS} from '../processes/parse_run_metrics.nf'

workflow NANOPORE_QC {
    main:

        MERGE_FILTER_FASTQ( barcodes_tuple )

        merged_filtered_fastq = MERGE_FILTER_FASTQ.out.merged_fastq
            .filter{ run, barcode, fastq_file -> fastq_file.countFastq() > params.min_reads_per_barcode }

        QC_RUN( merged_filtered_fastq )

        PARSE_QC_RUN( QC_RUN.out.stats, sample_sheet, parse_nanostat )
        
        MERGE_PARSED_STATS( PARSE_QC_RUN.out.parsed_stats, merge_parsed_run )

        if(params.merge_all) {
            grouped_files_all = MERGE_PARSED_STATS.out.merged_parsed_stats
            .collect()
            MERGE_MERGED_PARSED_STATS( grouped_files_all, merge_parsed_run)
        }

        if(params.parse_run_metrics){
            PARSE_RUN_METRICS( run_metrics , parse_metrics )
        }
}