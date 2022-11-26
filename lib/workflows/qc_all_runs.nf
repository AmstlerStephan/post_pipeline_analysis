nextflow.enable.dsl = 2

requiredParams = [
    'input', 
    'all_runs'
]

for (param in requiredParams) {
    if (params[param] == null) {
      exit 1, "Parameter ${param} is required."
    }
}

// scripts
merge_parsed_run = file( "${projectDir}/bin/merge_parsed_run.R", checkIfExists: true)

runs = Channel.fromPath("${params.input}/run*", type: 'dir')

include {NANOPORE_QC} from './nanopore_qc.nf'

include {MERGE_MERGED_PARSED_STATS} from '../processes/merge_merged_parsed_stats.nf'

workflow QC_ALL_RUNS {
    main:

        sample_sheet = file("${runs}/**${params.sample_sheet}", checkIfExists: true)
        print "${runs}/**${params.sample_sheet}"
        NANOPORE_QC( runs )

}

/*
        if(params.merge_all) {
            grouped_files_all = MERGE_PARSED_STATS.out.merged_parsed_stats
            .collect()
            MERGE_MERGED_PARSED_STATS( grouped_files_all, merge_parsed_run)
        }
*/