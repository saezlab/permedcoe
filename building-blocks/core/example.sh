#!/usr/bin/env bash

FILE=/tmp/Cell_line_RMA_proc_basalExp.txt.zip
if test -f "$FILE"; then
    echo "$FILE exists."
else
    wget https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip -P /tmp/
fi

unzip /tmp/Cell_line_RMA_proc_basalExp.txt.zip -d /tmp/
mv /tmp/Cell_line_RMA_proc_basalExp.txt /tmp/gex.tsv

# Export to CSV (raw) and normalized
preprocess_bb -i /tmp/gex.tsv GENE_SYMBOLS GENE_title FALSE TRUE TRUE DATA. -o gex.csv
preprocess_bb -i /tmp/gex.tsv GENE_SYMBOLS GENE_title TRUE TRUE TRUE DATA. -o gex_n.csv

# Example of computing TF enrichment for the first cell line (column 906826)
# Use progeny to compute pathway activities
progeny_bb -i gex.csv Human 80 GENE_SYMBOLS TRUE GENE_title FALSE 1 FALSE TRUE -o progeny11.csv

# TODO: This should be done for all columns, exporting a file per column (loop for columns, can be in parallel)
tfenrichment_bb -i gex_n.csv 906826 GENE_SYMBOLS tf FALSE 10 'A,B,C' TRUE -o 906826_tf.csv

# TODO: Run CARNIVAL for each column (can be in parallel)
# carnivalpy_bb

# TODO: Merge progeny11.csv with a matrix with samples x carnival features


# Train and model using drug/cell features to predict IC50 responses (use default data from repo except progeny11)
ml_bb -i .x .x progeny11.csv 200 0.1 0.001 10 0.1 0.1 -o model.npz
