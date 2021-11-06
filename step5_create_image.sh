#!/bin/bash

# Create a base custome image for jetson nano
# vuquangtrong@gmail.com
#
# step 5: create image

##########
echo "Get environment"

. ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Create image"

pushd $WORK_DIR/Linux_for_Tegra/tools

./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r 300
