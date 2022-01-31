# DecoupleR BB

This building block uses the decoupler.R script from the toolset container.

Main steps:
- Generate the container image with singularity from the toolset (see https://github.com/saezlab/permedcoe/tree/master/containers)
- Install permedcoe python tool ([install.sh](https://github.com/PerMedCoE/permedcoe/tree/8d98d8e3532475b560a068ce41237c5728b5d375) script)
- Install this building block (`pip install -e .` from the dir. which contains the setup.py script)
- Run `python -b decoupler_bb -i decoupler_bb/test/example/de_input_example.csv -o example.csv`

TODO: Create a Makefile 
