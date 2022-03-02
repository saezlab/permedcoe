#!/bin/bash

tmpdir="tmpresult"

if [ ! -d ${tmpdir} ]; then   
    mkdir $tmpdir
fi

# Read the list of cells to process
readarray -t cells < cell_list_full.txt
echo "A total of ${#cells[@]} cells will be processed"

# Download gene expression data from GDSC. Remove the DATA. prefix from the columns
if [ ! -f ${tmpdir}/gex.csv ]; then
    singularity run --app preprocess toolset/toolset.sif --tsv TRUE https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip --remove DATA. ${tmpdir}/gex.csv
fi

# Do the same but this time scale also genes across cell lines
if [ ! -f ${tmpdir}/gex_n.csv ]; then
    singularity run --app preprocess toolset/toolset.sif --tsv FALSE --scale TRUE ${tmpdir}/gex.csv ${tmpdir}/gex_n.csv
fi

# Use the gene expressoin data to run Progeny and estimate pathway activities
if [ ! -f ${tmpdir}/progeny.csv ]; then
    singularity run --app progeny toolset/toolset.sif --ntop 100 --perms 1 --zscore FALSE --verbose TRUE ${tmpdir}/gex.csv ${tmpdir}/progeny.csv
fi

# Get SIF from omnipath
if [ ! -f ${tmpdir}/network.csv ]; then
    singularity run --app omnipath toolset/toolset.sif ${tmpdir}/network.csv
fi

for cell in "${cells[@]}"
do
    echo "Processing $cell"
    if [ -d ${tmpdir}/${cell} ]; then
        echo "Directory already exists, skipping..."
    else
        mkdir ${tmpdir}/${cell}
        cp ${tmpdir}/network.csv ${tmpdir}/${cell}/    
        # Compute enrichment on the given cell line    
        singularity run --app tfenrichment toolset/toolset.sif --export_carnival TRUE --id_col GENE_SYMBOLS --weight_col $cell ${tmpdir}/gex_n.csv ${tmpdir}/${cell}/measurements.csv
        singularity run -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" carnivalpy/carnivalpy.sif ${tmpdir}/${cell} gurobi_mip 0 0.1 300 ${tmpdir}/${cell}/out.rds ${tmpdir}/${cell}/carnival.csv
        rm ${tmpdir}/${cell}/network.csv
        rm ${tmpdir}/${cell}/out.rds
    fi
done

singularity run --app feature_merger carnivalpy/carnivalpy.sif --merge_csv_file ${tmpdir}/progeny.csv --feature_file genelist.txt ${tmpdir} cell_features.csv

# TODO: After all cells are evaluated, merge all carnival values into a matrix with cell lines x genes
#singularity run --app ml tf-jax.sif --drug_features .x --cell_features cell_features.csv --test_drugs 0.1 --test_cells 0.1 --reg 0.01 .x model.npz
singularity run --app ml tf-jax/tf-jax.sif --drug_features .none --cell_features cell_features.csv --test_cells 0.1 --reg 0.01 .x model.npz


# Run Inverse Carnival on the first sample. This requires gurobi installed with a license. Can be installed with conda, e.g conda install -c gurobi gurobi=9.5.0
# Then register a license with grbgetkey. The solver can be passed by mounting the directory that contains the binary files
#singularity exec -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" toolset.sif Rscript --vanilla scripts/carnivalr.R gurobi /opt/env/bin/gurobi_cl /opt/permedcoe/carnivalpy/examples/ex1/network.csv /opt/permedcoe/carnivalpy/examples/ex1/measurements.csv /opt/permedcoe/carnivalpy/examples/ex1/perturbations.csv

#singularity exec -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" toolset.sif Rscript --vanilla scripts/carnivalr.R --timelimit 60 gurobi /opt/env/bin/gurobi_cl sif.csv tf_906826.csv
#singularity run --app carnival carnivalpy.sif . --solver cbc --opt_tol 0.1 --export carnival.csv

# Params are: <dir with CSVs> <solver name> <penalty> <mip tolerance> <maxtime> <R out file> <CSV out file>
#singularity run -B $CONDA_PREFIX:/opt/env --env "LD_LIBRARY_PATH=/opt/env/" carnivalpy/carnivalpy.sif tmpresult/cell_example gurobi_mip 0 0.1 600 cell_data/out.rds cell_data/carnival.csv




