#!/bin/bash

# Translate script arguments to singularity command
singularity run -W . --app codax codax.sif "$@"

