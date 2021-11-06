#!/bin/bash

# Create a base custome image for jetson nano
# vuquangtrong@gmail.com
#
# step 1: make rootfs

##########
echo "Get environment"

. ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Install tools"

apt install -y --no-install-recommends \
    curl \
    wget \
    debootstrap \
    qemu-user-static \
    binfmt-support \
    libxml2-utils \
    e2fsprogs \
    coreutils \
    parted \
    gdisk \

##########
echo "Debootstrap a base"

PACKAGES=

if [ ! $JETSON_PACKAGE == "online" ]; then

echo "Add packages for offline install"

PACKAGES=\
libasound2,\
libcairo2,\
libdatrie1,\
libegl1,\
libegl1-mesa,\
libevdev2,\
libfontconfig1,\
libgles2,\
libgstreamer1.0-0,\
libgstreamer-plugins-base1.0-0,\
libgtk-3-0,\
libharfbuzz0b,\
libinput10,\
libjpeg-turbo8,\
libpango-1.0-0,\
libpangocairo-1.0-0,\
libpangoft2-1.0-0,\
libpixman-1-0,\
libpng16-16,\
libunwind8,\
libwayland-client0,\
libwayland-cursor0,\
libwayland-egl1-mesa,\
libx11-6,\
libxext6,\
libxkbcommon0,\
libxrender1,\
locales,\
ca-certificates,\
device-tree-compiler,\
python,\
python3,\

fi

if [ ! -f $ARCH-$RELEASE.tgz ]
then
    echo "Download $ARCH-$RELEASE.tgz"
    debootstrap \
        --verbose \
        --foreign \
        --make-tarball=$ARCH-$RELEASE.tgz \
        $(if [ ! -z $PACKAGES]; then echo '--include=$PACKAGES'; fi ) \
        --arch=$ARCH \
        $RELEASE \
        $ROOT_DIR \
        $REPO
fi

echo "Install $ARCH-$RELEASE.tgz"
debootstrap \
    --verbose \
    --foreign \
    --unpack-tarball=$(realpath $ARCH-$RELEASE.tgz) \
    $(if [ ! -z $PACKAGES]; then echo '--include=$PACKAGES'; fi ) \
    --arch=$ARCH \
    $RELEASE \
    $ROOT_DIR \
    $REPO

##########
echo "Install virtual machine"

install -Dm755 $(which qemu-aarch64-static) $ROOT_DIR/usr/bin/qemu-aarch64-static
install -Dm644 /usr/share/keyrings/ubuntu-archive-keyring.gpg $ROOT_DIR/usr/share/keyrings/ubuntu-archive-keyring.gpg

##########
echo "Unpack $ROOT_DIR"

chroot $ROOT_DIR /debootstrap/debootstrap --second-stage
