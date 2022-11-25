library(tidyverse)
library(data.table)
library(argparser)
library(jsonlite)

parser <- arg_parser("Commandline parser")
parser <- add_argument(parser, "--nanostat_tsv", help = "NanoStat tsv file")
argv <- parse_args(parser)

nanostat_tsv <- argv$nanostat_tsv
filename <- str_split(basename(nanostat_tsv), "\\.", simplify = TRUE)[1]
info <- str_split(filename, "_", simplify = TRUE)
barcode <- info[1]
run <- info[2]
min_length <- info[3]
min_qscore <- info[4]

nanostat <- read_tsv(nanostat_tsv) %>%
transpose(make.names = "Metrics") %>%
mutate(
  run = run,
  barcode = barcode,
  min_length = min_length,
  min_qscore = min_qscore
)

filename_nanostat <- paste(filename, "_parsed", ".tsv", sep = "")
write_tsv(nanostat, filename_nanostat)