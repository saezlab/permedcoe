import os

# Decorator imports
from permedcoe import constraint       # To define constraints needs (e.g. number of cores)
from permedcoe import container        # To define container related needs
from permedcoe import binary           # To define binary to execute related needs
from permedcoe import mpi              # To define an mpi binary to execute related needs (can not be used with @binary)
from permedcoe import task             # To define task related needs
# @task supported types
from permedcoe import FILE_IN          # To define file type and direction
from permedcoe import FILE_OUT         # To define file type and direction
from permedcoe import FILE_INOUT       # To define file type and direction
from permedcoe import DIRECTORY_IN     # To define directory type and direction
from permedcoe import DIRECTORY_OUT    # To define directory type and direction
from permedcoe import DIRECTORY_INOUT  # To define directory type and direction
# Other permedcoe available functionalities
from permedcoe import get_environment  # Get variables from invocation (tmpdir, processes, gpus, memory)

# Try to locate the container, otherwise take from env
from common import get_container
container_file = get_container("toolset.sif")


def function_name(*args, **kwargs):
    """ Extended python interface:
    To be used only with PyCOMPSs - Enables to define a workflow within the building block.
    Tasks are not forced to be binaries: PyCOMPSs supports tasks that are pure python code.
    # PyCOMPSs help: https://pycompss.readthedocs.io/en/latest/Sections/02_App_Development/02_Python.html
    Requirement: all tasks should be executed in a container (with the same container definition)
                 to ensure that they all have the same requirements.
    """
    print("Building Block entry point to be used with PyCOMPSs")
    # TODO: (optional) Pure python code calling to PyCOMPSs tasks (that can be defined in this file or in another).



@container(engine="SINGULARITY", image=container_file)
@binary(binary="Rscript --vanilla /opt/preprocess.R")
@task(input_file=FILE_IN, output_file=FILE_OUT)
def preprocess(input_file=None, output_file=None,
               col_genes_flag='-c', col_genes='GENE_SYMBOLS',
               scale_flag='-s', scale='FALSE',
               exclude_cols_flag='-e', exclude_cols='GENE_title',
               tsv_flag='-t', tsv='FALSE',
               verbose_flag='-v', verbose='TRUE'):
    pass


def invoke(input, output, config):
    # preprocess -i file.csv GENE_SYMBOLS GENE_title FALSE TRUE TRUE -o out.csv
    var_inputs = ['input_file', 'col_genes', 'exclude_cols', 'scale', 'tsv', 'verbose']
    # Assign only the provided variables
    kwargs = {k: v for k, v in zip(var_inputs[:len(input)], input)}
    kwargs['output_file'] = output[0]
    print(kwargs)
    preprocess(**kwargs)
    