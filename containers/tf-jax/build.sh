#!/bin/bash


sudo singularity build tf-jax.sif tf-jax.singularity
chmod +x tf-jax.sif
singularity sign --keyidx 1 tf-jax.sif
sudo cp -rf tf-jax.sif /opt/containers/
./tf-jax.sif python ml.py .x /tmp/model.npz --drug_features .none --cell_features .x --test_cells 0.1



