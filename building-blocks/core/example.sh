#!/usr/bin/env bash

FILE=/tmp/Cell_line_RMA_proc_basalExp.txt.zip
if test -f "$FILE"; then
    echo "$FILE exists."
else
    wget https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip -P /tmp/
fi

unzip /tmp/Cell_line_RMA_proc_basalExp.txt.zip -d /tmp/
mv /tmp/Cell_line_RMA_proc_basalExp.txt /tmp/gex.tsv

preprocess -i /tmp/gex.tsv GENE_SYMBOLS GENE_title FALSE TRUE TRUE -o gex.csv
preprocess -i /tmp/gex.tsv GENE_SYMBOLS GENE_title TRUE TRUE TRUE -o gex_n.csv
tfenrichment -i gex_n.csv DATA.906826 GENE_SYMBOLS tf FALSE 10 'A,B,C' TRUE -o 906826_tf.csv
progeny -i gex.csv Human 60 GENE_SYMBOLS TRUE GENE_title FALSE 3000 TRUE TRUE -o progeny11.csv
