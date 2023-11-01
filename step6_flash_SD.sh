#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 6: flash SD card

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
echo "Check that $1 is a block device"

if [ ! -b $1 ] || [ "$(lsblk | grep -w $(basename $1) | awk '{print $6}')" != "disk" ]; then
	echo "$1 is not a block device!!!"
	exit 1
fi

##########
IMAGE=${WORK_DIR}/Linux_for_Tegra/tools/${JETSON_BOARD}_${RELEASE}_${JETSON_PLAT}_${JETSON_REL}_${JETSON_DESKTOP}.img
echo "Using ${IMAGE}"


##########
if [ "$(mount | grep $1)" ]; then
    echo "Unmount $1"
	for mount_point in $(mount | grep $1 | awk '{ print $1}'); do
		sudo umount $mount_point 
	done
fi

##########
echo "Flash $1"
dd if=${IMAGE} of=$1 bs=4M conv=fsync status=progress

##########
echo "Extend the partition"

partprobe $1
sgdisk -e $1

end_sector=$(sgdisk -p $1 |  grep -i "Total free space is" | awk '{ print $5 }')
start_sector=$(sgdisk -i 1 $1 | grep "First sector" | awk '{print $3}')

echo "start_sector = ${start_sector}"
echo "end_sector = ${end_sector}"

sgdisk -d 1 $1
sgdisk -n 1:${start_sector}:${end_sector} $1
sgdisk -c 1:APP $1

##########
echo "Extend the filesystem"

if [[ $(basename $1) =~ mmc ]]; then
	e2fsck -fp $1"p1"
	resize2fs $1"p1"
fi

if [[ $(basename $1) =~ sd ]]; then
	e2fsck -fp $1"1"
	resize2fs $1"1"
fi

sync

echo "DONE!"
