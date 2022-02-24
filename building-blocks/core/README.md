# UKHD Building Blocks

This package contains the list of building blocks produced by UKHD.

## Prerequisites

- Python >= 3.6
- [Singularity](https://singularity.lbl.gov/docs-installation)
- `permedcoe` base package: `python3 -m pip install permedcoe`

In addtion to the dependencies, it is necessary to generate the associated
singularity images that are available here: https://github.com/saezlab/permedcoe/tree/master/containers

They **MUST be available and exported respectively in the following environment variables**
before its usage:

```bash
export PERMEDCOE_SINGULARITY="/path/to/images/"
```

### Installation

This package provides an automatic installation script:

```bash
./install.sh
```

This script creates a file `installation_files.txt` to keep track of the
installed files.
It is used with the `uninstall.sh` script to uninstall the Building Block
from the system.


## Export BB

The `export_bb` building block converts from the csv files required by CARNIVAL (the PKN .sif file, the measurements csv file, and the perturbations or inputs csv file) to a hdf5 format required by the refactored version of CARNIVAL.

Example usage:

```
export_bb -i sif.csv measurements.csv inputs.csv TRUE -o file.h5
```

[Here](https://github.com/saezlab/permedcoe/tree/master/containers/toolset/scripts/examples/export) there is toy data to try.


## Carnival BB

The `carnival_bb` building block contains the refactored Carnival C++ with the new Ant Colony Optimization (ACO) in C++ with support for OpenMP and MPI. The hdf5 file required as an input can be generated with the `export_bb` building block.

Example usage:

```
carnival_bb -i file.h5 -o .
```

[Here](https://github.com/saezlab/permedcoe/blob/master/containers/parallel-solvers/examples/carnival_toy_example.h5) is an example of already converted CSV data into h5 that can be used to try CARNIVAL.

TODO: Update BB definition to select a folder where to export files.

## Carnivalpy BB

The `carnivalpy_bb` building block is the refactored vanilla CARNIVAL R version to Python with support for many commercial and non-commercial open source MILP solvers.

Usage:

```
carnivalpy_bb -i <input folder> <penalty> <solver name> -o <output path>
```
The input folder should contain three files named `sif.csv` with the PKN, `measurements.csv` with the TF activities, and `inputs.csv` with the perturbed nodes. [Here](https://github.com/saezlab/permedcoe/tree/master/containers/toolset/scripts/examples/export) there is toy data to try. For example:

```
carnivalpy_bb -i example/ 0.0001 cbc -o .
```

This runs CARNIVAL with a penalty of 0.0001 and using the CBC solver. Penalty refers to the sparsity penalty used in CARINVAL. For more information please refer to https://saezlab.github.io/CARNIVAL/ and the CARNIVAL R vignettes.

## CellNopt BB

The `cellnopt_bb` building block is the refactored CellNopt in C++ with the ACO solver with OpenMP/MPI support.

```
cellnopt_bb -i <h5 file> -o .
```

[Here](https://github.com/saezlab/permedcoe/blob/master/containers/parallel-solvers/examples/cellnopt_toy_example.h5) is an example of already converted CSV data into h5 that can be used to try CARNIVAL.

## Preprocess BB

The `preprocess_bb` building block preprocess gene expression data for running other methods that requires this type of data, such as CARNIVAL.

Usage:

```
preprocess_bb -i <gex csv> <id column> <exclude col> <scale> <is tsv> <verbose> <remove substr col>
```

Example using [GDSC data](https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Data/preprocessed/Cell_line_RMA_proc_basalExp.txt.zip). This example processes the csv file, asigns the `GENE_SYMBOL` column as the id containg gene labels, removes any column containing the string `GENE_title`, scales the data, imports it as a TSV file instead of CSV, enables verbose output, and removes the 'DATA.' prefix for every column in the dataset:

```
preprocess_bb -i gex_file GENE_SYMBOLS GENE_title FALSE TRUE TRUE DATA. -o out.csv
```

This wraps the script for processing in the `toolset.sif` container: https://github.com/saezlab/permedcoe/blob/master/containers/toolset/scripts/preprocess.R

## Progeny BB

The `progeny_bb` building block uses PROGENy to extract pathway activities from gene expression data. Please refer to https://saezlab.github.io/progeny/ for documentation.

Usage:

```
progeny_bb -i <gex data> <organism> <top genes> <gene col> <remove cols> <permutations> <z-scores> <verbose> -o output.csv
```

There are two supported organism for Progeny: `Human` and `Mouse`. Recommended settings is to use no permutations (use 1 for no perms) on normalized data across conditions (use `preprocess_bb`) and with z-scores disabled.

Example with the GDSC data already normalized with `preprocess_bb`:

```
progeny_bb -i gex.csv Human 60 GENE_SYMBOLS TRUE GENE_title FALSE 1 FALSE TRUE -o progeny11.csv
```

The output file contains 11 pathway activity values per condition (column) on the original data.

## TF enrichment BB

The `tfenrichment_bb` uses [DecoupleR](https://saezlab.github.io/decoupleR/) and [Dorothea](https://saezlab.github.io/dorothea/) to estimate Transcription Factor activities from perturbational data. Please refer to for more documentation.

Usage:

```
tfenrichment_bb -i <gex csv> <sample col> <id col> <source col> <use tsv> <regulon min size> <confidence list> <verbose> -o tf_sample.csv
```
The `<sample col>` refers to the name of the column containing differential expression values (e.g t-statistic from DESeq2) between a control/treatment condition for example, or just log-fold change. The `<id col>` contains the name of the column for gene ids. The `<source col>` should be `tf` (no need to change). The `<regulon min size>` is the min number of targets for a TF to be considered (e.g 10). The `<confidence list>` is the confidence levels for estimation of TFs from Dorothea (e.g 'A,B,C') (see https://saezlab.github.io/dorothea/ for documentation). The `<verbose>` produces verbose outputs. The final result contains the TF activities.

This is a wrapper for https://github.com/saezlab/permedcoe/blob/master/containers/toolset/scripts/tf_enrichment.R. More information about the meaning of the inputs is described there.

Example from normalized GEX data from GDSC using `preprocess_bb` on sample `DATA.906826`. Note that here we assume that genes are normalized across columns and so the control vs condition is the given column against the other conditions as control:

```
tfenrichment -i gex.csv DATA.906826 GENE_SYMBOLS tf FALSE 10 'A,B,C' TRUE -o 906826_tf.csv
```

## ML Building Block

The `ml_bb` building block implements the Matrix Factorization approach for prediction of target values with or without side features using [JAX](https://github.com/google/jax). This is a wrapper for https://github.com/saezlab/permedcoe/blob/master/containers/tf-jax/ml.py. This can be used to predict e.g drug responses on cell lines from partial observations of drug/cell responses.

There are two ways of using the building block. For training mode and for inference mode.

Training mode:

```
ml_bb -i <response csv> <row features csv> <col features csv> <epochs> <ADAM Learning rate> <regularization> <latent size> <test proportion rows> <test proportion cols> -o <npz model>
```

* `<response csv>`: CSV with the matrix to predict (e.g IC50 drug/cell responses) for training (see [this](https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/IC50) example). If the file is a `.npz` file, then the model is imported and this is run in inference mode for predictions. If `.x` is provided, the example file is used.
* `<row features csv>`: CSV with row features (e.g drug targets). See [this](https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/target) example. If `.x` is provided, the example file is used.
* `<col features csv>`: CSV with col features (e.g cell features). See [this](https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/progeny11) example. If `.x` is provided, the example file is used.
* `<epochs>`: Number of epochs for training. E.g 200.
* `<ADAM lr>`: Learning rate for the ADAM solver. E.g 0.1. Recommended <= 0.1. Lower values slow down the convergence.
* `<regularization>`: L2 regularization weight. E.g 0.001.
* `<latent size>`: Number of dimensions for the latent matrices to be estimated from the data. As a rule of thumb, this should be at most the minimum number of features for cells or drugs used. Larger values might create overfitted models.
* `<test proportion rows>`: If row features are provided, this is the proportion of samples removed from training for validation.
* `<test proportion cols>`: If col features are provided, this is the proportion of samples removed from training for validation.

Example (using example files):

```
ml_bb -i .x .x .x 200 0.1 0.001 10 0.1 0.1 -o model.npz
```

For prediction using a `model.npz` file:

```
ml_bb -i .x drug_features.csv cell_features.csv 0 0 0 0 0 0 -o predictions.csv
```


