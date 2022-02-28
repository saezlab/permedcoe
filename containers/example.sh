#!/bin/bash

mkdir tmpresult
mkdir tmpresult/cell_example

# Download gene expression data from GDSC. Remove the DATA. prefix from the columns
singularity run --app preprocess toolset/toolset.sif --tsv TRUE https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip --remove DATA. tmpresult/gex.csv

# Do the same but this time scale also genes across cell lines
singularity run --app preprocess toolset/toolset.sif --tsv FALSE --scale TRUE tmpresult/gex.csv tmpresult/gex_n.csv

# Use the gene expressoin data to run Progeny and estimate pathway activities
singularity run --app progeny toolset/toolset.sif --ntop 100 --perms 1 --zscore FALSE --verbose TRUE tmpresult/gex.csv tmpresult/progeny.csv

# Estimate TF activities for the first cell line (column = 906826) using the normalized genes across samples
mkdir cell_data
singularity run --app tfenrichment toolset/toolset.sif --export_carnival TRUE --id_col GENE_SYMBOLS --weight_col 906826 tmpresult/gex_n.csv tmpresult/cell_example/measurements.csv

# Get SIF from omnipath
singularity run --app omnipath toolset/toolset.sif tmpresult/cell_example/network.csv

# Run Inverse Carnival on the first sample. This requires gurobi installed with a license. Can be installed with conda, e.g conda install -c gurobi gurobi=9.5.0
# Then register a license with grbgetkey. The solver can be passed by mounting the directory that contains the binary files
#singularity exec -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" toolset.sif Rscript --vanilla scripts/carnivalr.R gurobi /opt/env/bin/gurobi_cl /opt/permedcoe/carnivalpy/examples/ex1/network.csv /opt/permedcoe/carnivalpy/examples/ex1/measurements.csv /opt/permedcoe/carnivalpy/examples/ex1/perturbations.csv

#singularity exec -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" toolset.sif Rscript --vanilla scripts/carnivalr.R --timelimit 60 gurobi /opt/env/bin/gurobi_cl sif.csv tf_906826.csv
#singularity run --app carnival carnivalpy.sif . --solver cbc --opt_tol 0.1 --export carnival.csv

# Params are: <dir with CSVs> <solver name> <penalty> <mip tolerance> <maxtime> <R out file> <CSV out file>
singularity run -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" carnivalpy/carnivalpy.sif tmpresult/cell_example gurobi_mip 0.0001 0.1 300 /tmp/out.rds cell_data/out.csv



