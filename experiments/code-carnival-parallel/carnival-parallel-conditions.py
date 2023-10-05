#!/usr/bin/env python
# coding: utf-8


import corneto as cn
import time
import pandas as pd
import numpy as np
from joblib import Parallel, delayed
from time import time
from corneto.methods import runVanillaCarnival


def extract(df, cond):
    return df[cond][["feature", "score"]].set_index("feature").to_dict()['score']



if __name__ == '__main__':
    cn.info()
    df_panacea = pd.read_csv("panacea/data.tsv", sep="\t")
    df_pkn = pd.read_csv("panacea/pkn.tsv", sep="\t")
    interactions = [(row[1], row[2], row[3]) for row in df_pkn.itertuples()]
    
    def worker_function(condition, grb_threads=1, seed=0):
        #df_data, df_pkn, condition = data
        inputs = extract(
            df_panacea, 
            (df_panacea.compound == condition) & 
            (df_panacea.type == "perturbation")
        )
        outputs = extract(
            df_panacea, 
            (df_panacea.compound == condition) & 
            (df_panacea.type == "measurement")
        )
        pkn = [(row[1], row[2], row[3]) for row in df_pkn.itertuples()]
        P, G = runVanillaCarnival(
            inputs, 
            outputs, 
            interactions, 
            solver='GUROBI',
            verbose=False,
            backend_options=dict(
                verbosity=0, 
                MIPGap=0.10,
                TimeLimit=600,
                Seed=seed,
                Threads=grb_threads
            )
        )
        return 0
        
    times = []
    for n in [1, 2, 4, 8, 16, 32]:
        for t in [1, 2, 4, 8, 16]:
            for s in [0, 1, 2, 3]:
                print(n, t, s)
                conditions = df_panacea.compound.unique().tolist()
                start = time()
                results = Parallel(
                    n_jobs=n, 
                    verbose=10
                )(delayed(worker_function)(condition, t, s) for condition in conditions)
                times.append((n, t, s, time() - start))
            # Update after every iteration
            df = pd.DataFrame(times, columns=['cpus', 'grb_threads', 'seed', 'time'])
            df.to_csv('times.tsv', sep='\t', index=False)
    print(times)


