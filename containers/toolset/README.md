# Toolset contained

The idea of this container is to modularize the access to the different tools from Saez-Rodriguez's group using the same entry point. This container depends on saeztools.sif container.


## Build the container

```
> sudo singularity build toolset.sif toolset.singularity
```


## Usage examples

### Preprocessing:

```
singularity run --app preprocess toolset.sif --tsv TRUE https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip gex.csv
```

### Progeny:

Use progeny to estimate pathway activities for the GDSC gene expression data

```
singularity run --app progeny toolset.sif --ntop 100 --perms 1000 gex.csv progeny.csv
```

### TF Activities

Perform TF enrichment using Dorothea + DecoupleR w/VIPER for the first cell lines in the GEX.csv data

```
singularity run --app tfenrichment toolset.sif --id_col GENE_SYMBOLS --weight_col DATA.906826 toolset.sif gex.csv tf_906826.csv
```

