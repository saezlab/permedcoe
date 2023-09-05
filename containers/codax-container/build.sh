#!/bin/bash


sudo singularity build ml-jax.sif ml-jax.singularity
chmod +x ml-jax.sif
singularity sign --keyidx 1 ml-jax.sif
sudo cp -rf ml-jax.sif /opt/containers/
./ml-jax.sif python ml.py .x /tmp/model.npz --drug_features .none --cell_features .x --test_cells 0.1



