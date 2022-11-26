nextflow.enable.dsl = 2

requiredParams = [
    'input'
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

include {MERGE_FILTER_FASTQ} from '../processes/merge_filter_fastq.nf'
include {QC_RUN} from '../processes/qc_run.nf'
include {PARSE_QC_RUN} from '../processes/parse_qc_run.nf'
include {MERGE_PARSED_STATS} from '../processes/merge_parsed_stats.nf'
include {PARSE_RUN_METRICS} from '../processes/parse_run_metrics.nf'

workflow NANOPORE_QC {
    take:
        barcodes
        sample_sheets
        run_metrics
        barcode_sizes
    main:
        MERGE_FILTER_FASTQ( barcodes )

        merged_filtered_fastq = MERGE_FILTER_FASTQ.out.merged_fastq
            .filter{ run, barcode, fastq_file -> fastq_file.countFastq() > params.min_reads_per_barcode }

        QC_RUN( merged_filtered_fastq )

        QC_RUN.out.stats
        .map{ run, barcode, fastq -> 
            sample_sheet = sample_sheets.get("$run")
            tuple( run, barcode, fastq, sample_sheet)}
        .set{ stats_sample_sheet }
        
        PARSE_QC_RUN( stats_sample_sheet , parse_nanostat )

        PARSE_QC_RUN.out.parsed_stats
        .map{ run, stats -> 
            tuple groupKey(run, barcode_sizes.get("$run")), stats }
        .groupTuple()
        .set{ collected_parsed_stats }
        
        MERGE_PARSED_STATS( collected_parsed_stats, merge_parsed_run )

        if(params.parse_run_metrics){
            PARSE_RUN_METRICS( run_metrics, parse_metrics )
        }

        emit:
        merged_tsv = MERGE_PARSED_STATS.out.merged_parsed_stats
}