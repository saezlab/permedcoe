#!/usr/bin/env Rscript --vanilla

library(progeny)
library(dorothea)
library(readr)
library(optparse)
library(tibble)
library(dplyr)

parser <- OptionParser(
  usage = "usage: %prog expression_csv_file_or_url output_file [options]",
  option_list = list(
    make_option(c("-o", "--organism"), default="Human", help="Organism (Mouse, Human). Default = Human"),
    make_option(c("-i", "--ntop"), default=100, help="Number of top genes used for estimation of TF activities. Default = 100"),
    make_option(c("-c", "--col_genes"), default="GENE_SYMBOLS", help="Name of the column containing the gene symbols. Default = GENE_SYMBOLS"),
    make_option(c("-s", "--scale"), default=T, help="Scale the data. Default = TRUE"),
    make_option(c("-e", "--exclude_cols"), default="GENE_title", help="Exclude columns containing the given string. Default = 'GENE_title'"),
    make_option(c("-t", "--tsv"), default=F, help="Assume file is TSV instead of CSV. Default = FALSE"),
	make_option(c("-p", "--perms"), default=2000, help="Number of permutations to estimate the null distribution. Default = 2000"),
	make_option(c("-z", "--zscore"), default=T, help="Get Z-scores. Default = TRUE"),
    make_option(c("-v", "--verbose"), default=F, help="Verbosity (default False)")
  ),
  add_help_option = T,
  prog = "Use PROGENy to calculate pathway activities from gene expression (csv file with conditions, or URL)",
  formatter = IndentedHelpFormatter
)

arguments <- parse_args(parser, positional_arguments = T)
verbose <- arguments$options$verbose
file <- arguments$args[1]

if (verbose) {
  sprintf("Loading expression data from %s...", file)
}

if (startsWith(file, "http") || startsWith(file, "www.")) {
  url <- file
  if (verbose) {
    print("Downloading file...")
  }
  file <- tempfile()
  download.file(url, file, mode = "wb")
}

if (arguments$options$tsv) {
  df <- read_tsv(file)  
} else {
  df <- read_csv(file)
}

df <- df[!is.na(df[arguments$options$col_genes]),]

# Estimate pathway activities with PROGENy
df_progeny_score <- df %>% 
  replace(is.na(.), 0) %>% 
  select(-contains(arguments$options$exclude_cols)) %>%
  column_to_rownames(var = arguments$options$col_genes) %>%
  as.matrix() %>%
  progeny::progeny(., scale=arguments$options$scale, 
                   organism=arguments$options$organism, 
                   top = arguments$options$ntop, 
                   verbose = arguments$options$verbose,
				   z_score = arguments$options$zscore,
				   perm = arguments$options$perms) %>%
  as_tibble()


if (verbose) {
  sprintf("Exporting to %s...", arguments$args[2])
}

df_progeny_score %>% write_csv(arguments$args[2])

