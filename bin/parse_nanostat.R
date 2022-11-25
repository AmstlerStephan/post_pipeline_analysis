install.packages("argparser")

library(tidyverse)
library(data.table)
library(argparser)
library(jsonlite)

parser <- arg_parser("Commandline parser")
parser <- add_argument(
  parser,
  "--nanostat_tsv",
  help = "NanoStat tsv file"
)
parser <- add_argument(
  parser,
  "--sample_sheet",
  help = "Sample sheet to join barcodes and samples"
)
parser <- add_argument(
  parser,
  "--run",
  help = "Sample sheet to join barcodes and samples"
)
parser <- add_argument(
  parser,
  "--barcode",
  help = "Sample sheet to join barcodes and samples"
)
parser <- add_argument(
  parser,
  "--min_qscore",
  help = "Sample sheet to join barcodes and samples"
)
parser <- add_argument(
  parser,
  "--min_read_length",
  help = "Sample sheet to join barcodes and samples"
)

argv <- parse_args(parser)
nanostat_tsv <- argv$nanostat_tsv
sample_sheet <- argv$sample_sheet
barcode <- argv$barcode
run <- argv$run
min_read_length <- argv$min_read_length
min_qscore <- argv$min_qscore

barcode_nanopore <- paste0("NB", str_sub(barcode, start = -2))

nanostat <- read_tsv(nanostat_tsv) %>%
  transpose(make.names = "Metrics") %>%
  mutate(
    run = run,
    barcode = barcode,
    barcode_nanopore = barcode_nanopore,
    min_read_length = min_read_length,
    min_qscore = min_qscore,
    is_V14 = str_detect(run, "V14")
  )

sample_barcode_overview <-
  fromJSON(sample_sheet)

run_stats <- nanostat %>%
  inner_join(
    sample_barcode_overview,
    by = c("barcode_nanopore" = "Barcode")
  )

filename_run_stats <-
  paste(
    run,
    barcode,
    min_read_length,
    min_qscore,
    "parsed",
    sep = "_"
  )

write_tsv(run_stats, paste0(filename_run_stats, ".tsv"))