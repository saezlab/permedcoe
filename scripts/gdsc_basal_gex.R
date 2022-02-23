library(tidyverse)
library(decoupleR)
library(progeny)
library(tibble)
library(CARNIVAL)
library(OmnipathR)
library(ggplot2)
library(purrr)

# Read basal gene expression
url <- "https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip"
zip_file <- tempfile(fileext = ".zip")
download.file(url, zip_file, mode = "wb")
df <- read_tsv(zip_file)
df <- df[!is.na(df$GENE_SYMBOLS),] 
df_cell_meta <- read_delim("C:/Users/pablo/Documents/work/projects/permedcoe/code/permedcoe/scripts/gdsc_cells.csv", delim=";")

df_expr <-
  df %>% 
  select(-GENE_title) %>% 
  rename_with(~gsub("DATA.", "", .x, fixed = TRUE)) %>%
  column_to_rownames("GENE_SYMBOLS")

df_pca <- as.data.frame(prcomp(t(df_expr))$x)[,c(1,2)]
df_pca$type <- df_cell_meta$gdsc_tissue_1[match(rownames(df_pca), df_cell_meta$cosmic_id)]
ggplot(df_pca,aes(x=PC1,y=PC2,color=type))+geom_point()
#ggplot(df_pca[df_pca$type %in% c("leukemia", "lymphoma"),], aes(x=PC1,y=PC2,color=type))+geom_point()



######### PROGENY

# Estimate pathway activities with PROGENy
df_progeny_score <- df %>% 
  replace(is.na(.), 0) %>% 
  select(., -GENE_title) %>%
  rename_with(~gsub("DATA.", "", .x, fixed = TRUE)) %>%
  column_to_rownames("GENE_SYMBOLS") %>%
  as.matrix() %>%
  progeny::progeny(., scale=TRUE, 
                   organism="Human", 
                   top = 100, 
                   verbose = TRUE,
                   z_scores = FALSE,
                   perm=1)

rownames(df_progeny_score) <- gsub('X', '', rownames(df_progeny_score))

df_pca <- as.data.frame(prcomp(df_progeny_score)$x)[,c(1,2)]
df_pca$type <- df_cell_meta$gdsc_tissue_1[match(rownames(df_pca), df_cell_meta$cosmic_id)]
ggplot(df_pca,aes(x=PC1,y=PC2,color=type))+geom_point()


############### TF ACTIVITIES

# Calculate TF activities. There is no DE expression here
# but since there are many samples, we would use the average
# as the reference condition to compare against. Better approach
# would be to separate by tissue.
dorothea_interactions <- dorothea::dorothea_hs %>%
  subset(confidence %in% c("A", "B", "C")) %>%
  dplyr::mutate(likelihood = 1)


# Select gene expression columns and normalize by row
df_gex <- df %>% select(starts_with("DATA")) %>% rename_with(~gsub("DATA.", "", .x, fixed = TRUE))
df_gexn <- (df_gex - apply(df_gex, 1, mean))/apply(df_gex, 1, sd)
rownames(df_gexn) <- df$GENE_SYMBOLS

df_pca <- as.data.frame(prcomp(t(df_gexn))$x)[,c(1,2)]
df_pca$type <- df_cell_meta$gdsc_tissue_1[match(rownames(df_pca), df_cell_meta$cosmic_id)]
ggplot(df_pca,aes(x=PC1,y=PC2,color=type))+geom_point()



# Example for sample 1
cell <- "906826"

decoupler_input <- df_gexn %>% 
  dplyr::select(cell) %>%
  as.matrix()

tf_activity_results_viper <- run_viper(
  mat = decoupler_input, 
  network = dorothea_interactions, 
  .source = "tf",
  .target = "target",
  .mor = "mor",
  .likelihood = "likelihood"
) %>%
  dplyr::mutate(adj_p = p.adjust(p_value, method = "BH"))


# For all cell lines
# https://adisarid.github.io/post/2019-01-24-purrrying-progress-bars/
pb <- dplyr::progress_estimated(ncol(df_gexn))
fn_viper <- function(col){
  pb$tick()$print()
  m <- as.matrix(col)
  rownames(m) <- rownames(df_gexn)
  act <- run_viper(
    mat = m, 
    network = dorothea_interactions, 
    .source = "tf",
    .target = "target",
    .mor = "mor",
    .likelihood = "likelihood"
  ) %>%
    dplyr::mutate(adj_p = p.adjust(p_value, method = "BH")) %>%
    select(score)
  return(act)
}
# Apply to cols
df_tfs <- 
  df_gexn %>% 
  purrr::map_dfc(fn_viper)

colnames(df_tfs) <- colnames(df_gexn)
df_tfs$gene <- tf_activity_results_viper$source
df_tfs <- df_tfs %>% column_to_rownames("gene")
df_tfs <- df_tfs[,1:1017]
df_tfs <- df_tfs %>% rename_with(~gsub("DATA.", "", .x, fixed = TRUE))

df_pca <- as.data.frame(prcomp(t(df_tfs))$x)[,c(1,2)]
df_pca$type <- df_cell_meta$gdsc_tissue_1[match(rownames(df_pca), df_cell_meta$cosmic_id)]
ggplot(df_pca,aes(x=PC1,y=PC2,color=type))+geom_point()

ids <- match(colnames(df_tfs), df_cell_meta$cosmic_id)
tissues <- df_cell_meta$gdsc_tissue_1[ids]
subset_tissue <- colnames(df_tfs)[(tissues != 'leukemia') & (tissues != 'myeloma')]
subset_tissue <- subset_tissue[!is.na(subset_tissue)]


df_subset_tfs <- df_tfs[,subset_tissue]
df_pca <- as.data.frame(prcomp(t(df_subset_tfs))$x)[,c(1,2)]
df_pca$type <- df_cell_meta$gdsc_tissue_1[match(rownames(df_pca), df_cell_meta$cosmic_id)]
ggplot(df_pca,aes(x=PC1,y=PC2,color=type))+geom_point()



# Measurements for CARNIVAL
tf_carnival <-
  tf_activity_results_viper %>% 
  dplyr::filter(condition == cell) %>%
  dplyr::select(source, p_value) %>%
  dplyr::mutate(weight = sign(tf_activity_results_viper$score)*as.integer(p_value < 0.01)) %>%
  dplyr::select(-p_value) %>%
  dplyr::filter(weight != 0) %>%
  column_to_rownames("source")

tf_activity_results <- run_wmean(
  mat = decoupler_input, 
  network = dorothea_interactions, 
  times = 10000,
  .source = "tf",
  .target = "target",
  .mor = "mor",
  .likelihood = "likelihood"
) %>%
  subset(statistic == "norm_wmean") %>%
  dplyr::mutate(adj_p = p.adjust(p_value, method = "BH"))

# Example running CARNIVAL

omniR <- import_omnipath_interactions()
omnipath_sd <- omniR %>% dplyr::filter(consensus_direction == 1 &
                                         (consensus_stimulation == 1 | 
                                            consensus_inhibition == 1
                                         ))

# changing 0/1 criteria in consensus_stimulation/inhibition to -1/1
omnipath_sd$consensus_stimulation[which( omnipath_sd$consensus_stimulation == 0)] = -1
omnipath_sd$consensus_inhibition[which( omnipath_sd$consensus_inhibition == 1)] = -1
omnipath_sd$consensus_inhibition[which( omnipath_sd$consensus_inhibition == 0)] = 1

# check consistency on consensus sign and select only those in a SIF format
sif <- omnipath_sd[,c('source_genesymbol', 'consensus_stimulation', 'consensus_inhibition', 'target_genesymbol')] %>%
  dplyr::filter(consensus_stimulation==consensus_inhibition) %>%
  unique.data.frame()

sif$consensus_stimulation <- NULL
colnames(sif) <- c('source', 'interaction', 'target')

# remove complexes
sif$source <- gsub(":", "_", sif$source)
sif$target <- gsub(":", "_", sif$target)

tf_activity <- tf_carnival$weight
names(tf_activity) <- rownames(tf_carnival)

opts <- defaultLpSolveCarnivalOptions()
opts$betaWeight <- 1e-6

runInverseCarnival(
  tf_activity,
  sif,
  weights = NULL,
  carnivalOptions = opts
)