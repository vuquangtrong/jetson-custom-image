#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# do all defined steps

##########
echo "Check root permission"

if [ "x$(whoami)" != "xroot" ]; then
	echo "This script requires root privilege!!!"
	exit 1
fi

##########

source ./step0_env.sh
./step1_make_rootfs.sh
./step2_customize_rootfs.sh
./step3_apply_bsp.sh
pushd custom_bsp_for_nano_dev_kit
./step3b_customize_bsp.sh
popd
./step5_create_image.sh

echo "Done!"
