#!/bin/bash

# Create a base custome image for jetson nano
# vuquangtrong@gmail.com
#
# step 4: flash image

##########
echo "Get environment"

. ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Flash image"

pushd $WORK_DIR/Linux_for_Tegra

./flash.sh jetson-nano-devkit mmcblk0p1

exit
