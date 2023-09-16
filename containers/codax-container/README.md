# GPU-enabled Logic ODE for signaling using Neural ODEs

[CODAX](https://github.com/saezlab/codax) is a new tool to accelerate the training of dynamic models of cell signaling using mechanistic logic ODEs on the GPU and CPU.

## Get the container

```
singularity pull library://pablormier/permedcoe/codax:1.0.0
```

## Build (and sign) the container
The container is made for x86 CPUs and the jax installation needs a CPU with AVX support. This is because the jaxlib wheel was build on a system with AVX support. Mac M1 notebooks don't fullfill these requirements.

```
sudo singularity build codax.sif codax.singularity
singularity sign --keyidx N codax.sif
```
NOTE: For signing the container make sure that you have created your keys first. Please see https://sylabs.io/guides/3.0/user-guide/signNverify.html for more info.

## Usage


```
singularity run --app codax codax.sif [-h] [--sim_time_start SECONDS] [--sime_time_end SECONDS] [--sime_time_steps SECONDS] 
                                      [--load_params PICKLE_FILE] [--perturbs CSV_FILE] [--output_model FILE] 
                                      [--output_sim FILE] [--iters NUM_ITERS] [--lr LEARNING_RATE] [--fig FIG] [--figname FILE]
                                      sif_file midas_data_file
```

- `sim_time_start`: seconds at which the simulation starts (default=0)
- `sim_time_end`: seconds at which the simulation stops (default=10)
- `sim_time_steps`: Number of timepoints linearly spaced between start and end (default=10)
- `load_params`: File with a pretrained model (pkl file) to use.
- `perturbs`: File containing a list of perturbations, where each file is a parameter and the new value, e.g.: `TNFa_n_NFkB, 0`.
- `output_model`: File to store the trained model (default='model.pkl')
- `output_sim`: File containing the output of a simulation, for example using `perturbs` file on a trained model (default='sim.pkl')
- `iters`: Number of iteration steps for the Neural ODE (default=500)
- `lr`: Learning rate for the gradient descent method (default=1e-3)
- `fig`: 1 to generate a png file with the simulation, 0 otherwise (default=1)
- `figname`: name of the file for the figure with the simulated data, only applies if `--fig 1` (default='sim.png')

Example using the default data:

```
singularity run -W . --app codax codax.sif --output_model 'model.pkl' --figname 'sim.png' . .
```

After training a model, it can be used to simulate interventions:

```
singularity run -W . --app codax codax.sif --load_params example/params.pkl --perturbs example/pert.txt
```

Running an example included in the repository:

```
# Let's train dynamic signaling model with CODAX. We need an experimental setting file and a network SIF file
cat example/MD-test.csv
cat example/PKN-test.sif
./codax.sh --output_model model.pkl --figname sim.png example/PKN-test.sif example/MD-test.csv
# Now let's use the trained model and do some perturbation to predict the effects on signaling
./codax.sh --load_params model.pkl --perturbs example/pert.txt example/PKN-test.sif example/MD-test.csv
```
