#!/bin/bash


sudo singularity build tf-jax.sif tf-jax.singularity 
singularity sign --keyidx 1 tf-jax.sif
sudo cp -rf tf-jax.sif /opt/containers/


