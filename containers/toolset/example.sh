#!/bin/bash

singularity run --app preprocess toolset.sif --tsv TRUE https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip gex.csv

singularity run --app preprocess toolset.sif --tsv FALSE --scale TRUE gex.csv gex_n.csv

singularity run --app progeny toolset.sif --ntop 100 --perms 1000 gex.csv progeny.csv

singularity run --app tfenrichment toolset.sif --id_col GENE_SYMBOLS --weight_col DATA.906826 gex_n.csv tf_906826.csv

