import os

from permedcoe import container
from permedcoe import binary
from permedcoe import task
from permedcoe import DIRECTORY_IN
from permedcoe import FILE_OUT


@container(engine="SINGULARITY", image="toolset.sif")
@binary(binary="Rscript --vanilla /opt/tf_enrichment.R")
@task(data=DIRECTORY_IN, result=FILE_OUT)
def tf_enrichment(input_file=None, output_file=None, verbose='-v'):
    """
    The Definition is equal to:
        Rscript --vanilla /opt/tf_enrichment.R <de_input_file> <output_file>
    """
    pass


def invoke(input, output, config):
    print(input, output)
    tf_enrichment(input_file=input[0], output_file=output[0])
