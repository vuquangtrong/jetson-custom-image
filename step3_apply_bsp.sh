#!/bin/bash

# Create a base custome image for jetson nano
# vuquangtrong@gmail.com
#
# step 3: apply JETSON_BSP

##########
echo "Get environment"

. ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########

if [ ! -f $JETSON_BSP ]
then 
    echo "Download JETSON_BSP"
    wget $JETSON_BSP_URL
fi

##########
echo "Extract JETSON_BSP"

if [ ! -d $WORK_DIR/Linux_for_Tegra ]
then
    tar jxpf $JETSON_BSP -C $WORK_DIR
fi

##########
echo "Copy rootfs"

rm -rf $WORK_DIR/Linux_for_Tegra/rootfs
cp -rf $ROOT_DIR $WORK_DIR/Linux_for_Tegra/

declare -a remove_files=(
    "dev/random"
    "dev/urandom"
)

for file in "${remove_files[@]}"; do
    uri=$WORK_DIR/Linux_for_Tegra/rootfs/$file
    if [ -e "$uri" ]
    then
        rm -f $uri
    fi
done

if [ $JETSON_PACKAGE == "online" ]; then

##########
echo "Copy extlinux.conf"

pushd $WORK_DIR/Linux_for_Tegra/

install -Dm644 bootloader/extlinux.conf rootfs/boot/extlinux/extlinux.conf

else

##########
echo "Apply jetson binaries"

rm -f $WORK_DIR/Linux_for_Tegra/rootfs/etc/apt/sources.list.d/nvidia-l4t-apt-source.list

pushd $WORK_DIR/Linux_for_Tegra/

./apply_binaries.sh

fi

##########
echo "Add user"

pushd $WORK_DIR/Linux_for_Tegra/tools

./l4t_create_default_user.sh -u $JETSON_USR -p $JETSON_PWD -n $JETSON_NAME --autologin --accept-license
