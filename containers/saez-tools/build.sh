#!/bin/bash


sudo singularity build saeztools.sif saeztools.singularity 
singularity sign --keyidx 1 saeztools.sif
sudo cp -rf saeztools.sif /opt/containers/


