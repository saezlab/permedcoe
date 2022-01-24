#!/usr/bin/env Rscript --vanilla

library(progeny)
library(tools)
library(dorothea)
library(readr)
library(optparse)

parser <- OptionParser(
  usage = "usage: %prog expression_csv_file_or_url output_file [options]",
  option_list = list(
    make_option(c("-o", "--organism"), default="Human", help="Organism (Mouse, Human). Default = Human"),
    make_option(c("-i", "--ntop"), default=100, help="Number of top genes used for estimation of TF activities. Default = 100"),
    make_option(c("-s", "--scale"), default=T, help="Scale the data. Default = TRUE"),
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
    if (verbose) {
        
    }
}

if (tolower(tools::file_ext(file)) == "zip") {

}


DE_data <- read_csv(arguments$args[1])
if (verbose) {
  DE_data
}

DE_matrix <- DE_data %>% 
  dplyr::select(arguments$options$id_col, arguments$options$weight_col) %>% 
  dplyr::filter(!is.na(arguments$options$weight_col)) %>% 
  column_to_rownames(var = arguments$options$id_col) %>%
  as.matrix()

dorothea::dorothea_hs
data(dorothea_hs, package = "dorothea")
regulons <- dorothea_hs %>%
  dplyr::filter(confidence %in% unlist(strsplit(arguments$options$confidence,",")))

network <- intersect_regulons(DE_matrix, regulons, tf, target, minsize = 5)
network$likelihood <- 1

tf_activity <- decoupleR::run_viper(
  DE_matrix, 
  network, 
  .source=arguments$options$source,
  minsize = arguments$options$minsize,
  verbose = verbose,
  eset.filter = FALSE
  )

if (verbose) {
  sprintf("Exporting to %s...", arguments$args[2])
}

write_csv(tf_activity, arguments$args[2])
