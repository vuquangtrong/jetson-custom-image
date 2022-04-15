#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 2: customize rootfs

##########
echo "Check root permission"

if [ "x$(whoami)" != "xroot" ]; then
	echo "This script requires root privilege!!!"
	exit 1
fi

##########
echo "Get environment"

source ../jetson-custom-image/step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Mount dependency points"

# these mount points are needed for chroot?
# if script halts before unmounting these point, you have to unmount manually
# that is the reason, this script is called in a wrapper, see step2_customize_rootfs.sh
for mnt in sys proc dev dev/pts tmp; do
    mount -o bind "/$mnt" "${ROOT_DIR}/$mnt"
done

##########
echo "Add repos for ${ARCH}"

cat << EOF > ${ROOT_DIR}/etc/apt/apt.conf.d/99verify-peer.conf
Acquire::https::Verify-Peer "false";
Acquire::https::Verify-Host "false";
EOF

cat << EOF > ${ROOT_DIR}/etc/apt/sources.list
deb [arch=${ARCH}] ${REPO} ${RELEASE} main restricted universe multiverse
deb [arch=${ARCH}] ${REPO} ${RELEASE}-updates main restricted universe multiverse
deb [arch=${ARCH}] ${REPO} ${RELEASE}-security main restricted universe multiverse
EOF

##########
echo "Update repo source list"

chroot ${ROOT_DIR} apt install --fix-broken

##########
echo "Unmount dependency points"

for mnt in tmp dev/pts dev proc sys; do
    umount "${ROOT_DIR}/$mnt"
done
