library(jsonlite)
library(dplyr)
library(tidyverse)
library(janitor)
library(data.table)

parser <- arg_parser("Commandline parser")
parser <- add_argument(
  parser,
  "--run_metrics",
  help = "markdown containing run metrics"
)
parser <- add_argument(
  parser,
  "--run",
  help = "Sample sheet to join barcodes and samples"
)
argv <- parse_args(parser)
run_metrics <- argv$run_metrics
run <- argv$run

general_info <- scan(Sys.glob(run_metrics), what = "character")
json_data <- vector()
key <- general_info[5]

for (i in 4:length(general_info)) {
  if (general_info[i - 1] == ",") {
    key <- general_info[i]
  }
  if (general_info[i - 1] == ":") {
    value <- general_info[i]
  }
  if (i %% 4 == 0 && i != 4) {
    json_data[[key]] <- value
  }
  if (general_info[i] == "}") {
    break
  }
}

run_info <- data.frame(as.list(json_data))

run_info_filename <-
paste(
  run,
  "metrics",
  sep = "_"
)

write_tsv(run_info, paste0(run_info_filename, ".tsv"))
