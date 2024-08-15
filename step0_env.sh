#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 0: set up environment

##########
echo "Set target architecture"

ARCH=arm64

echo "Set target distro"

# Ubuntu release version, e.g. Ubuntu 18.04.6
RELEASE=bionic

# Use below script to get the fastest repo, after that skip script to run faster
# if [ -z "${REPO}" ]
# then
#     REPO=$(./find_mirrors.sh ${ARCH} ${RELEASE} main speed | sort -k 1 | head -n 1 | awk '{print $2}')
# fi

REPO=http://repo.jing.rocks/ubuntu-ports
# If REPO is empty, http://ports.ubuntu.com/ubuntu-ports will be used, or set a REPO below

echo "Set target platform"

JETSON_BOARD=jetson-nano-devkit
JETSON_STORAGE=mmcblk0p1
JETSON_BOARD_IMG=jetson-nano
JETSON_BOARD_REV=300
JETSON_PLAT=t210
JETSON_REL=r32.7.5
JETSON_BSP=jetson-210_linux_r32.7.5_aarch64.tbz2
JETSON_BSP_URL=https://developer.nvidia.com/downloads/embedded/l4t/r32_release_v7.5/t210/jetson-210_linux_r32.7.5_aarch64.tbz2

echo "Set target directories"

ROOT_DIR=/tmp/jetson-custom/rootfs
WORK_DIR=/tmp/jetson-custom/build

echo "Set system users"

ROOT_PWD=root
JETSON_NAME=nvidia
JETSON_USR=jetson
JETSON_PWD=cccccc

echo "Set desktop manager"

# leave it empty to not install any DE
# JETSON_DESKTOP=

# just a minimal desktop
# JETSON_DESKTOP=openbox

# some panels from lxde
# JETSON_DESKTOP=lxde

# look better and lightweight
JETSON_DESKTOP=xubuntu

# more similar to ubuntu
# JETSON_DESKTOP=ubuntu-mate

echo "Set network settings"

WIFI_SSID=
WIFI_PASS=

##########
echo "Prepare environment"

mkdir -p ${ROOT_DIR}
mkdir -p ${WORK_DIR}

echo "ARCH = ${ARCH}"
echo "RELEASE = ${RELEASE}"
echo "REPO = ${REPO}"

echo "JETSON_PLAT = ${JETSON_PLAT}"
echo "JETSON_REL = ${JETSON_REL}"
echo "JETSON_BSP = ${JETSON_BSP}"
echo "JETSON_BSP_URL = ${JETSON_BSP_URL}"

echo "ROOT_DIR = ${ROOT_DIR}"
echo "WORK_DIR = ${WORK_DIR}"

echo "ROOT_PWD =${ROOT_PWD}"
echo "JETSON_NAME = ${JETSON_NAME}"
echo "JETSON_USR = ${JETSON_USR}"
echo "JETSON_PWD = ${JETSON_PWD}"
echo "JETSON_DESKTOP = ${JETSON_DESKTOP}"

echo "WIFI_SSID = ${WIFI_SSID}"
echo "WIFI_PASS = ${WIFI_PASS}"
