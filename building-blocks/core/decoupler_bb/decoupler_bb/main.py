import os

from permedcoe import container
from permedcoe import binary
from permedcoe import task
from permedcoe import DIRECTORY_IN
from permedcoe import FILE_OUT


@container(engine="SINGULARITY", image="toolset.sif")
@binary(binary="Rscript --vanilla /opt/decoupler.R")
@task(data=DIRECTORY_IN, result=FILE_OUT)
def decoupler_viper(data=None, result=None):
    """
    The Definition is equal to:
        Rscript --vanilla /opt/decoupler.R <de_input_file> <result_file>
    """
    pass


def invoke(input, output, config):
    """ Common interface.
    Args:
        input (list): List containing the model and data folder.
        output (list): list containing the output directory path.
        config (dict): Configuration dictionary (not used).
    Returns:
        None
    """
    decoupler_viper(data=input[0], result=output[0])
