import warnings
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
warnings.filterwarnings('ignore')

from codax.nn_cno import ode
import optax
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import sympy2jax
import jax
import requests
import tempfile
import os
import argparse
import pickle
from urllib.parse import urlparse


TEST_SIF = "https://raw.githubusercontent.com/saezlab/codax/main/codax/nn_cno/datasets/wcs_benchmark/PKN-test.sif"
TEST_DATA = "https://raw.githubusercontent.com/saezlab/codax/main/codax/nn_cno/datasets/wcs_benchmark/MD-test.csv"


def is_url(string):
    try:
        result = urlparse(string)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


def is_file(string):
    return os.path.isfile(string)


def download_file(url):
    # Create a temporary directory in the system's temp directory
    temp_dir = tempfile.mkdtemp()
    
    # Extract the file name from the URL
    file_name = url.split('/')[-1]
    
    # Create the full path for the file to be saved
    file_path = os.path.join(temp_dir, file_name)
    
    # Download the file from URL
    response = requests.get(url)
    
    if response.status_code == 200:
        # Write content into the file inside the temp directory
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        # Return the path of the temporary directory containing the file
        return file_path
    else:
        print(f"Failed to download the file. HTTP Status Code: {response.status_code}")
        return None

          

if __name__ == "__main__":
    print("Using JAX version", jax.__version__)
    print("Using sympy2jax version", sympy2jax.__version__)
    print("Using optax version", optax.__version__) 
    
    parser = argparse.ArgumentParser(description="CODAX UC2 dynamic model")
    parser.add_argument('sif_file', type=str, help='SIF model for signaling')
    parser.add_argument('data_file', type=str, help='MIDAS data file with the experimental conditions')
    parser.add_argument('--sim_time_start', type=int, default=0, help='Starting time for simulation')
    parser.add_argument('--sim_time_end', type=int, default=10, help='Ending time for simulation')
    parser.add_argument('--sim_time_steps', type=int, default=10, help='Time steps')
    parser.add_argument('--load_params', type=str, default="", help='Pickle file with the parameters of the dynamic model')
    parser.add_argument('--perturbs', type=str, default="", help='A file (csv) with perturbations, where keys are param names')
    parser.add_argument('--output_model', type=str, default="model.pkl", help='File to store the trained model')
    parser.add_argument('--output_sim', type=str, default="sim.pkl", help='File to store the simulation result')
    parser.add_argument('--iters', type=int, default=500, help='Number of iterations for training')
    parser.add_argument('--lr', type=float, default=1e-3, help='Learning rate for ADAM optimizer')
    parser.add_argument('--fig', type=int, default=1, help='Number of iterations for training')
    parser.add_argument('--figname', type=str, default='sim.png', help='Name of the figure with the simulation of the model on training data')
    args = parser.parse_args()

    if args.sif_file == ".":
        args.sif_file = TEST_SIF

    if args.data_file == ".":
        args.data_file = TEST_DATA
    
    if is_url(args.sif_file):
        sif_file = download_file(args.sif_file)
    else:
        sif_file = parser.sif_file

    print("SIF:", sif_file)
    if is_url(args.data_file):
        data_file = download_file(args.data_file)
    else:
        data_file = args.data_file
    print("DATA:", data_file)

    print("Creating logic ODE model...")
    c = ode.logicODE(sif_file, data_file)
    print("Preprocessing model...")
    c.preprocessing(compression=True,cutnonc=True,expansion=False)

    tsteps = jax.numpy.linspace(args.sim_time_start,args.sim_time_end,args.sim_time_steps)

    if len(args.load_params) > 0:
        print(f"Loading parameters from {args.load_params}")

        with open(args.load_params, "rb") as f:
            opt_params_dict = pickle.load(f)

        for k, v in opt_params_dict.items():
            print(f"{k:<15}: {v}")

        if len(args.perturbs) > 0:
            with open(args.perturbs, 'r') as f:
                perts = {key.strip(): float(value) for key, value in (line.strip().split(', ') for line in f)}
            print(f"Injecting the following perturbations from {args.perturbs}:")
            for k, v in perts.items():
                print(f"{k:<15}: {v}")
            opt_params_dict.update(perts)
            
        sim_res = c.simulate(ODEparameters=opt_params_dict, timepoints=tsteps, plot_simulation=True)
        if args.fig > 0:    
            plt.savefig(args.figname)

        if len(args.output_sim) > 0:
            with open(args.output_sim, "wb") as f:
                pickle.dump(sim_res, f)
            print(f"Saved simuation results in {args.output_sim}")
    else:

        print(f"Optimizing (iters={args.iters}, lr={args.lr})...")
        opt_params, results = c.fit(max_iter=args.iters, optimizer=optax.adam(learning_rate=args.lr), get_results=True)
        keys = list(c.get_ODEparameters())
        opt_param_dict = {k: v for k, v in zip(keys, np.array(opt_params))}
        for k, v in opt_param_dict.items():
            print(f"{k:<15}: {v}")
        print("Simulating...")
        sim_res = c.simulate( ODEparameters=opt_params, timepoints=tsteps, plot_simulation=True)
        print("Saving results...")
        
        if args.fig > 0:
            plt.savefig(args.figname)
        if len(args.output_model) > 0:
            with open(args.output_model, "wb") as f:
                pickle.dump(opt_param_dict, f)
            print(f"Saved model in {args.output_model}")

        if len(args.output_sim) > 0:
            with open(args.output_sim, "wb") as f:
                pickle.dump(sim_res, f)
            print(f"Saved simuation results in {args.output_sim}")
    
    print("Done.")
        
