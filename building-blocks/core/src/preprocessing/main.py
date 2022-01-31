import os

from permedcoe import container
from permedcoe import binary
from permedcoe import task
from permedcoe import DIRECTORY_IN
from permedcoe import FILE_OUT


@container(engine="SINGULARITY", image="toolset.sif")
@binary(binary="Rscript --vanilla /opt/preprocess.R")
@task(data=DIRECTORY_IN, result=FILE_OUT)
def preprocess(input_file=None, output_file=None, verbose_flag='-v', verbose='T'):
    """
    The Definition is equal to:
        Rscript --vanilla /opt/preprocess.R <url_or_file> <output_file>
    """
    pass


def invoke(input, output, config):
    preprocess(input_file=input[0], output_file=output[0])
