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
preprocess -i /tmp/gex.tsv GENE_SYMBOLS GENE_title FALSE TRUE TRUE DATA. -o gex.csv
preprocess -i /tmp/gex.tsv GENE_SYMBOLS GENE_title TRUE TRUE TRUE DATA. -o gex_n.csv
# Example of computing TF enrichment for the first cell line (column 906826)
# This should be done for all columns
tfenrichment -i gex_n.csv 906826 GENE_SYMBOLS tf FALSE 10 'A,B,C' TRUE -o 906826_tf.csv
# Use progeny to compute pathway activities
progeny -i gex.csv Human 80 GENE_SYMBOLS TRUE GENE_title FALSE 1 FALSE TRUE -o progeny11.csv
# Train and model using drug/cell features to predict IC50 responses (use default data from repo except progeny11)
ml -i .x .x progeny11.csv 200 0.1 0.001 10 0.1 0.1 -o model.npz
