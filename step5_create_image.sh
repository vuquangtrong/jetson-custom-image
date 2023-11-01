#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 5: create image

##########
echo "Check root permission"

if [ "x$(whoami)" != "xroot" ]; then
	echo "This script requires root privilege!!!"
	exit 1
fi

##########
echo "Get environment"

source ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
IMAGE=${JETSON_BOARD}_${RELEASE}_${JETSON_PLAT}_${JETSON_REL}_${JETSON_DESKTOP}.img
echo "Create image ${IMAGE}"

pushd ${WORK_DIR}/Linux_for_Tegra/tools

./jetson-disk-image-creator.sh -o ${IMAGE} -b ${JETSON_BOARD_IMG} -r ${JETSON_BOARD_REV}
