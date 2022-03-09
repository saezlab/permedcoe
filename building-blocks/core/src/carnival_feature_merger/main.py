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

# Find container file
# Try to locate the container, otherwise take from env
from common import get_container
container_file = get_container("carnivalpy.sif")



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
@binary(binary="/opt/miniconda/bin/python /opt/feature_merge.py")
@task(input_dir=DIRECTORY_IN, output_file=FILE_OUT)
def feature_merger(input_dir=None, output_file=None,
        feature_file_flag='--feature_file', feature_file=None,
        merge_csv_file_flag='--merge_csv_file', merge_csv_file=None,
        merge_csv_index_flag='--merge_csv_index', merge_csv_index=None,
        merge_csv_prefix_flag='--merge_csv_prefix', merge_csv_prefix=None):
    pass


def invoke(input, output, config):
    parser.add_argument('folder', type=str, help="Path containing the folders with the samples. Name of the folders are used for the name of the samples")
    parser.add_argument('output', type=str, help="Output file with the features, where rows are samples and columns features")
    parser.add_argument('--feature_file', type=str, default=None, help="File containing a list of features. If provided, only those features are retrieved from solutions.")
    parser.add_argument('--merge_csv_file', type=str, default=None, help="If provided, join the merged features into the given file.")
    parser.add_argument('--merge_csv_index', type=str, default="sample", help="If provided, join the merged features into the given file.")
    parser.add_argument('--merge_csv_prefix', type=str, default="F_", help="Prefix for the merged features")

    var_inputs = ['input_dir', 'feature_file', 'merge_csv_file', 'merge_csv_index', 'merge_csv_prefix']
    # Assign only the provided variables
    kwargs = {k: v for k, v in zip(var_inputs[:len(input)], input)}
    kwargs['output_file'] = output[0]
    print(kwargs)
    feature_merger(**kwargs)
