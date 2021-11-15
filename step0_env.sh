#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 0: set up environment

##########
echo "Set target release version"

ARCH=arm64
RELEASE=bionic
REPO=http://mirror.coganng.com/ubuntu-ports
# REPO=http://mirror.misakamikoto.network/ubuntu-ports

# If REPO is empty, http://ports.ubuntu.com/ubuntu-ports will be used

# Use below script to get the fastest repo
# if [ -z "${REPO}" ]
# then
#     REPO=$(./find_mirrors.sh arm64 bionic main speed | sort -k 1 | head -n 1 | awk '{print $2}')
# fi

echo "Set target platform"

JETSON_BOARD=jetson-nano-devkit
JETSON_STORAGE=mmcblk0p1
JETSON_BOARD_IMG=jetson-nano
JETSON_BOARD_REV=300
JETSON_PLAT=t210
JETSON_REL=r32.6
JETSON_BSP=jetson-210_linux_r32.6.1_aarch64.tbz2
JETSON_BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2

echo "Set target directories"

ROOT_DIR=/home/vqtrong/jetson-custom/rootfs
WORK_DIR=/home/vqtrong/jetson-custom/build

echo "Set system users"

ROOT_PWD=root

JETSON_NAME=rover
JETSON_USR=jetson
JETSON_PWD=cccc

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

WIFI_SSID="Your WiFi Acess Point"
WIFI_PASS="Your WiFi Password"

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
