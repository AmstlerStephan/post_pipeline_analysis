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



include { NANOPORE_QC } from './nanopore_qc.nf'

include {MERGE_MERGED_PARSED_STATS} from '../processes/merge_merged_parsed_stats.nf'

include { get_run_dirs } from '../functions/get_run_dirs.nf' params(input: params.input)

runs = get_run_dirs(params.input)

workflow QC_ALL_RUNS {
    for( run in runs ){
        NANOPORE_QC( run )
    }

    if( params.merge_all ){
        MERGE_MERGED_PARSED_STATS( NANOPORE_QC.out.merged_tsv, merge_parsed_run)
    }
}