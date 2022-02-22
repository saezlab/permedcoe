# CARNIVALpy Building Block

CARNIVALpy is an extension of the original CARNIVAL (CAusal Reasoning for Network identification using Integer VALue programming) for the identification of upstream reguatory signalling pathways from downstream gene expression. It is made on top of PICOS and Python-MIP and has support for many commercial and non-commercial solvers.

## Description

This building block uses the [containarized CARNIVALpy](https://github.com/saezlab/permedcoe/tree/master/containers/carnivalpy)

## User instructions

### Requirements

- Python >= 3.6
- [Singularity](https://singularity.lbl.gov/docs-installation)
- `permedcoe` base package: `python3 -m pip install permedcoe`

In addtion to the dependencies, it is necessary to generate the associated
singularity image [containarized CARNIVALpy](https://github.com/saezlab/permedcoe/tree/master/containers/carnivalpy).

They **MUST be available and exported in the following environment variables**
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

### Usage

The `carnivalpy` package provides a clear interface that allows
it to be used with multiple workflow managers (e.g. PyCOMPSs, NextFlow and
Snakemake).

It can be imported from python and invoked directly from a **PyCOMPSs**
application, or through the command line for other workflow managers
(e.g. Snakemake and NextFlow).

The command line is:

```bash
carnivalpy_bb -i <input folder> <penalty> <solver> -o .
```


### Example

There is one example in https://github.com/saezlab/permedcoe/tree/master/carnivalpy/examples/ex1 with 3 required files:
- network.csv: the SIF file with the Prior Knowledge Network. Can be obtained using the [omnipath building block](https://github.com/saezlab/permedcoe/blob/master/containers/toolset/scripts/omnipath.R)
- measurements.csv: CSV with two columns id,value, where id are gene symbols (as in the PKN), and value contains the gene fold changes (or 1, -1 if the gene is upregulated or downregulated for example)
- perturbation.csv: CSV with two columns id,value as in measurements.csv. This correspond to the perturbed genes upstream the measurements.

```
carnivalpy_bb -i example/ 0.0001 cbc -o .
```
This runs the carnivalpy building block using a penalty (sparsity of the final model) of 0.0001 and using the solver `cbc`. Other solvers can be used instead. See https://picos-api.gitlab.io/picos/introduction.html for the supported solvers.

### Uninstall

Uninstall can be achieved by executing the following scripts:

```bash
./uninstall.sh
./clean.sh
```

## License

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)

## Contact

<https://permedcoe.eu/contact/>
