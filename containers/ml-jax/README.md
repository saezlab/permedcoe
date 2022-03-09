# ML container for Matrix Factorization using JAX

This container implements different matrix factorization strategies using optional side information (drug features and cell features) for the prediction of IC50 values. This container can be used for example to train a model for the prediction IC50 responses for new cells using known drugs, the potency of a new drug on known cell lines, or the prediction of new drug/cell responses.

## Get the container

```
> singularity pull library://pablormier/permedcoe/tf-jax:1.0.0
```

## Build (and sign) the container


```
> sudo singularity build tf-jax.sif tf-jax.singularity
> singularity sign --keyidx N tf-jax.sif
```
NOTE: For signing the container make sure that you have created your keys first. Please see https://sylabs.io/guides/3.0/user-guide/signNverify.html for more info.

## Usage


```
singularity run --app ml tf-jax.sif [-h] [--drug_features DRUG_FEATURES] [--cell_features CELL_FEATURES] [--epochs EPOCHS] 
                                    [--adam_lr ADAM_LR] [--reg REG] [--test_drugs TEST_DRUGS] [--test_cells TEST_CELLS] [--latent_size LATENT_SIZE]
                                    input_file output_file
```
- `input_file`: csv containing the response matrix (drugs x cells) with the IC50 values or npz model with the trained parameters. Provide `.x` to use the default example data to train a model. If the extension ends with `.npz`, instead of training, it runs in inference mode and predicts the drugs x cells matrix from the provided features.
- `output_file`: file with the trained parameters (e.g `model.npz`) or csv file to export the predictions if the model runs in inference mode.
- `-h`: show description of the arguments
- `--drug_features`: csv containing the drug features (drug x features matrix). Provide `.x` to use [default example data](https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/target), or `.none` to ignore the use of drug features.
- `--cell_features`: csv containing the cell features (cell x features matrix). Provide `.x` to use [default example data](https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/progeny11), or `.none` to ignore the use of cell features.
- `--epochs`: Number of iterations for training the model. Default = 200.
- `--adam_lr`: Learning rate for the ADAM optimizar. Default = 0.1.
- `--reg`: l2 regularization weight. Default = 0.01.
- `--test_drugs`: proportion of drugs to remove from the training to test the model (only applicable if drug features are provided). Default = 0.1.
- `--test_cells`: proportion of cells to remove from the training to test the model (only applicable if cell features are provided). Default = 0.1.
- `--latent_size`: size of the latent vector. Default = 10.

Example using the default data, and exporting the trained model to the `model.npz` file:

```
> singularity run --app ml tf-jax.sif --drug_features .x --cell_features .x --test_drugs 0.1 --test_cells 0.1 --reg 0.01 .x model.npz
```

Make predictions:

```
> singularity run --app ml tf-jax.sif --drug_features .x --cell_features .x model.npz result.csv
```
