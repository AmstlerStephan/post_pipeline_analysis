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

argv <- parse_args(parser)
nanostat_tsv <- argv$nanostat_tsv
sample_sheet <- argv$sample_sheet

filename <- str_split(basename(nanostat_tsv), "\\.", simplify = TRUE)[1]
info <- str_split(filename, "_", simplify = TRUE)
barcode <- info[1]
barcode_nanopore <- paste0("NB", str_sub(barcode, start = -2))
run <- info[2]
min_length <- info[3]
min_qscore <- info[4]

nanostat <- read_tsv(nanostat_tsv) %>%
  transpose(make.names = "Metrics") %>%
  mutate(
    run = run,
    barcode = barcode,
    barcode_nanopore = barcode_nanopore,
    min_length = min_length,
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

filename_run_stats <- paste(filename, "_parsed", ".tsv", sep = "")
write_tsv(run_stats, filename_run_stats)