#!/bin/bash

# configure a new user account for the bluesky class
#
# run from root:  su -l -c /home/user_setup.sh - USERNAME

#   su -l -s /bin/bash test3

############################################################
# operating environment

. /opt/miniconda3/bin/activate class_2021_03

mkdir -p ~/bin

# prefixes for GP and AD IOCs
cat > ~/.bash_aliases << EOF
#
# IOC prefixes
export GP_IOC_PREFIX="gp${USER}:"
export AD_IOC_PREFIX="ad${USER}:"

# only listen to docker IOCs running on this workstation
# export DOCKER_IOC_BROADCAST_ADDRESS=172.17.255.255
export EPICS_CA_ADDR_LIST=172.17.255.255
export EPICS_CA_AUTO_ADDR_LIST=NO

EOF
cat /home/add2bash.rc >> ~/.bash_aliases

export GP_IOC_PREFIX="gp${USER}:"
export AD_IOC_PREFIX="ad${USER}:"

############################################################
# IPython

export IPYTHON_DIR=${HOME}/.ipython-bluesky

ipython profile create --ipython-dir=${IPYTHON_DIR} --profile=bluesky

env | sort > env.txt

cd ${IPYTHON_DIR}/profile_bluesky/startup
tar xzf /home/instrument.tar.gz

cat > run_instrument.py << EOF
from instrument.collection import *
EOF

############################################################
# bash starter script

cp /home/blueskyStarter.sh ./
pushd ~/bin
/bin/rm -f ./blueskyStarter.sh
ln -s ${IPYTHON_DIR}/profile_bluesky/startup/blueskyStarter.sh ./
popd

############################################################
# databroker configuration YAML file

mkdir -p ~/.local/share/intake
cat > ~/.local/share/intake/databroker_mongodb.yml << EOF
sources:
  class_2021_03:
    args:
      asset_registry_db: mongodb://localhost:27017/${USER}-bluesky
      metadatastore_db: mongodb://localhost:27017/${USER}-bluesky
    driver: bluesky-mongo-normalized-catalog
EOF

############################################################
# previously-collected data for analysis

cd ~
/bin/rm -f ~/.local/share/intake/databroker_unpack_class_data_examples.yml
databroker-unpack inplace "/opt/class_data_examples" class_data_examples
