import os

# Container definition for al building block of this package
try:
    CONTAINER_FOLDER = os.environ["PERMEDCOE_SINGULARITY"]
except KeyError:
    CONTAINER_FOLDER = '/opt/containers'

def get_container(name):
    if not os.path.exists(CONTAINER_FOLDER):
        raise FileNotFoundError(f"Folder {CONTAINER_FOLDER} does not exist")
    container = os.path.join(CONTAINER_FOLDER, name)
    if not os.path.isfile(container):
        raise FileNotFoundError(f"Cannot locate container in {container}")
    return container
