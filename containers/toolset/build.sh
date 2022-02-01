#!/bin/bash


sudo singularity build toolset.sif toolset.singularity 
singularity sign --keyidx 1 toolset.sif
sudo cp toolset.sif /opt/containers/


