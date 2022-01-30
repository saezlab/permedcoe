# Toolset contained

The idea of this container is to modularize the access to the different tools from Saez-Rodriguez's group using the same entry point. This container depends on saeztools.sif container.


## Build the container

```
> sudo singularity build toolset.sif toolset.singularity
```


## Usage examples

### Progeny:

Use progeny to estimate pathway activities for the GDSC gene expression data

```
singularity run --app progeny toolset.sif --tsv TRUE https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip out.csv
```

