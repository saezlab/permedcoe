import jax
import jax.numpy as jnp
import pandas as pd
import numpy as np
import argparse
from tqdm import tqdm
from jax.experimental import optimizers


DATA_LOGIC50 = "https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/IC50"
DATA_DRUG_FEATURES = "https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/target"
DATA_CELL_FEATURES = "https://raw.githubusercontent.com/saezlab/Macau_project_1/master/DATA/progeny11"

def load_ic50(file):
    df_logIC50 = pd.read_csv(file)
    df_logIC50 = df_logIC50.rename(columns={df_logIC50.columns[0]: 'drug'}).set_index('drug')
    df_logIC50.columns = df_logIC50.columns.astype(int)
    df_logIC50.columns.name = 'cell'
    df_logIC50 = df_logIC50.dropna(how='all', axis=0).dropna(how='all', axis=1)
    df_logIC50 = df_logIC50.groupby(level=0).mean() # merge duplicates
    return df_logIC50

def load_drug_features(file):
    df_drug_features = pd.read_csv(file)
    df_drug_features = df_drug_features.rename(columns={df_drug_features.columns[0]: 'drug'}).set_index('drug')
    df_drug_features = df_drug_features.groupby(level=0).first() # merge dups
    return df_drug_features

def load_cell_features(file):
    df_cell_features = pd.read_csv(file)
    df_cell_features = df_cell_features.rename(columns={df_cell_features.columns[0]: 'cell'}).set_index('cell')
    df_cell_features = df_cell_features.add_prefix("PROGENY_").reset_index().rename(columns={'index':'cell'}).set_index('cell')
    return df_cell_features

def initialize_weights(data, row_features=None, col_features=None, k=10):
    if row_features is not None:
        LD = np.random.normal(size=(k, row_features.shape[1]))
    else:
        LD = np.random.normal(size=(k, data.shape[0]))
    if col_features is not None:
        LC = np.random.normal(size=(k, col_features.shape[1]))
    else:
        LC = np.random.normal(size=(k, data.shape[1]))
    ld_bias = jnp.zeros((k, 1))
    lc_bias = jnp.zeros((k, 1))
    mu = 0.0
    return [LD, LC, ld_bias, lc_bias, mu]

@jax.jit
def mf(params):
    LD, LC, ld_bias, lc_bias, mu = params
    Dt = jnp.transpose(jnp.add(LD, ld_bias))
    C = jnp.add(LC, lc_bias)
    return jnp.dot(Dt, C) + mu

@jax.jit
def mf_with_row_features(params, row_features):
    LD, LC, ld_bias, lc_bias, mu = params
    D = jnp.add(jnp.dot(LD, jnp.transpose(row_features)), ld_bias)
    Dt = jnp.transpose(D)
    C = jnp.add(LC, lc_bias)
    return jnp.dot(Dt, C) + mu

@jax.jit
def mf_with_col_features(params, col_features):
    LD, LC, ld_bias, lc_bias, mu = params
    Dt = jnp.transpose(jnp.add(LD, ld_bias))
    C = jnp.add(jnp.dot(LC, jnp.transpose(col_features)), lc_bias)
    return jnp.dot(Dt, C) + mu

@jax.jit
def mf_with_features(params, row_features, col_features):
    LD, LC, ld_bias, lc_bias, mu = params
    Dt = jnp.transpose(jnp.add(jnp.dot(LD, jnp.transpose(row_features)), ld_bias)) 
    C = jnp.add(jnp.dot(LC, jnp.transpose(col_features)), lc_bias)
    return jnp.dot(Dt, C) + mu

# Implementation of MSE loss ignoring NaN values
@jax.jit
def loss_mse(X, X_hat):
    # Count the number of valid values in the matrix
    is_nan = jnp.isnan(X)
    n = jnp.sum(~is_nan)
    # Replace NaNs with 0s. It does not affect the loss
    # as we're going to compute the average ignoring 0s
    Xf = jnp.nan_to_num(X, nan=0.)
    # Put 0s on NaN positions
    X_hat_f = jnp.where(is_nan, 0., X_hat)
    # Sum of squared residuals
    sq = jnp.power(Xf - X_hat_f, 2)
    # Average using non missing entries
    return jnp.sum(sq) / n

@jax.jit
def predict(params, row_features=None, col_features=None):
    if row_features == None and col_features == None:
        X_hat = mf(params)
    elif row_features != None and col_features == None:
        X_hat = mf_with_row_features(params, row_features)
    elif col_features != None and row_features == None:
        X_hat = mf_with_col_features(params, col_features)
    else:
        X_hat = mf_with_features(params, row_features, col_features)
    return X_hat

@jax.jit
def loss_mf(params, X, row_features=None, col_features=None, reg=0.0):
    X_hat = predict(params, row_features, col_features)
    # Add regularization for latent matrices
    l2_ld = jnp.sum(jnp.power(params[0], 2))
    l2_lc = jnp.sum(jnp.power(params[1], 2))
    return loss_mse(X, X_hat) + reg*(l2_ld + l2_lc)

def optimize(X, params, opt=optimizers.adam(0.1), loss_fn=loss_mf, 
             loss_options=dict(), epochs=1000):
    opt_state = opt.init_fn(params)
    steps = tqdm(range(epochs))
    for step in steps:
        value, grads = jax.value_and_grad(loss_fn)(opt.params_fn(opt_state), X, **loss_options)
        opt_state = opt.update_fn(step, grads, opt_state)
        steps.set_postfix({'loss': "{:.4f}".format(value)})
    return opt.params_fn(opt_state)
    

if __name__ == "__main__":
    print("Using JAX version", jax.__version__)
    
    parser = argparse.ArgumentParser(description="ML UC2 model")
    parser.add_argument('--ic50', type=str, default=DATA_LOGIC50, help="Response file of IC50 values")
    parser.add_argument('--drug_features', type=str, default=DATA_DRUG_FEATURES, help="File with drug features")
    parser.add_argument('--cell_features', type=str, default=DATA_CELL_FEATURES, help="File with cell features")
    parser.add_argument('--model_file', type=str, default='model.npz', help="Name of the file used to store a trained model")
    parser.add_argument('--model', type=str, default=None, help='Path to a model file. If provided, features are used for inferring ic50 values instead of training')
    parser.add_argument('--epochs', type=int, default=1000, help='Number of epochs for training')
    parser.add_argument('--adam_lr', type=float, default=0.1, help='Learning rate for ADAM optimizer')
    parser.add_argument('--reg', type=float, default=1e-5, help='Regularization penalty for sparisty')
    parser.add_argument('--output_prediction', type=str, default='prediction.csv', help='Name of the file to store the predictions in inference mode')
    args = parser.parse_args()

    df_logIC50 = load_ic50(args.ic50)
    df_drug_features = load_drug_features(args.drug_features)
    df_cell_features = load_cell_features(args.cell_features)
    df_drug_features = df_drug_features.loc[df_logIC50.index] # align with target
    common = df_cell_features.index.intersection(df_logIC50.columns.astype(int))
    df_cell_features = df_cell_features.loc[common] # align with cols in target data
    df_logIC50 = df_logIC50.loc[:, common]
    print("Cell features", df_cell_features.shape)
    print("Drug features", df_drug_features.shape)

    row_features = df_drug_features.to_numpy()
    col_features = df_cell_features.to_numpy()

    if args.model is not None:
        print(f"Loading model from file {args.model}...")
        p = np.load(args.model, allow_pickle=True)
        params = [p['LD'], p['LC'], p['ld_bias'], p['lc_bias'], p['mu']]
        # predict
        X_hat = predict(params, row_features, col_features)
        df_pred = pd.DataFrame(X_hat, index=df_drug_features.index, columns=df_cell_features.index)
        print(df_pred)
        print(f"Saving to {args.output_prediction}...")
        df_pred.to_csv(args.output_prediction)
    else:
        print(f"Using ADAM with lr={args.adam_lr}, epochs={args.epochs}, l2 regularization={args.reg}")
        params = initialize_weights(df_logIC50, row_features=row_features, col_features=col_features)
        opt = optimizers.adam(args.adam_lr)
        params = optimize(df_logIC50.to_numpy(), params, epochs=args.epochs, opt=opt, 
                        loss_options={'row_features': row_features, 'col_features': col_features, 'reg': args.reg})
        LD, LC, ld_bias, lc_bias, mu = params
        if args.model_file is not None:
            print(f"Exporting model to {args.model_file}...")
            np.savez_compressed(args.model_file, LD=LD, LC=LC, ld_bias=ld_bias, lc_bias=lc_bias, mu=mu)
    print("Done.")
        