#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 1: make rootfs

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
echo "Install tools"

apt install -y --no-install-recommends \
    qemu-user-static \
    debootstrap \
    binfmt-support \
    libxml2-utils

##########
echo "Debootstrap a base"

# create a zip file for laster use
# delete the zip file to get new version of packages
# however, app packages will be updated later
if [ ! -f ${ARCH}-${RELEASE}.tgz ]
then
    echo "Download packages to ${ARCH}-${RELEASE}.tgz"
    debootstrap \
        --verbose \
        --foreign \
        --make-tarball=${ARCH}-${RELEASE}.tgz \
        --arch=${ARCH} \
        ${RELEASE} \
        ${ROOT_DIR} \
        ${REPO}
fi

echo "Install packages from ${ARCH}-${RELEASE}.tgz"
debootstrap \
    --verbose \
    --foreign \
    --unpack-tarball=$(realpath ${ARCH}-${RELEASE}.tgz) \
    --arch=${ARCH} \
    ${RELEASE} \
    ${ROOT_DIR} \
    ${REPO}

##########
echo "Install virtual machine"

# qemu-aarch64-static will be called by chroot
install -Dm755 $(which qemu-aarch64-static) ${ROOT_DIR}/usr/bin/qemu-aarch64-static

# ubuntu-keyring package can be installed, but this way is a bit faster ?
install -Dm644 /usr/share/keyrings/ubuntu-archive-keyring.gpg ${ROOT_DIR}/usr/share/keyrings/ubuntu-archive-keyring.gpg

##########
echo "Unpack ${ROOT_DIR}"

chroot ${ROOT_DIR} /debootstrap/debootstrap --second-stage
