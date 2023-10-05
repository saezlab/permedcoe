#!/bin/bash
#SBATCH --cpus-per-task=64
#SBATCH --mem=32G
#SBATCH --error=runs/corneto_%A.err
#SBATCH --output=runs/corneto_%A.out
#SBATCH --time=8:00:00
#SBATCH --chdir=/net/data.isilon/ag-saez/bq_prodriguez/projects/permedcoe/carnival-multi-parallel
#SBATCH --partition=gpusaez
#SBATCH --ntasks=1

# activate the conda environment called corneto
source $HOME/.bashrc
conda activate corneto
# also load the gurobi module 
module load numlib/gurobi/10.0.1

python carnival-parallel-conditions.py
