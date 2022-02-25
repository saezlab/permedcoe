#!/bin/bash


sudo singularity build carnivalpy.sif carnivalpy.singularity 
singularity sign --keyidx 1 carnivalpy.sif
sudo cp -rf carnivalpy.sif /opt/containers/


