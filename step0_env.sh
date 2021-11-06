#!/bin/bash

# Create a base custome image for jetson nano
# vuquangtrong@gmail.com
#
# step 0: set up environment

##########
echo "Set target release version"

ARCH=arm64
RELEASE=bionic
REPO=http://mirror.misakamikoto.network/ubuntu-ports
# REPO=http://mirror.coganng.com/ubuntu-ports
# REPO=http://ftp.lanet.kr/ubuntu-ports
# REPO=http://ports.ubuntu.com/ubuntu-ports

echo "Set target platform"

JETSON_PACKAGE=online
JETSON_PLAT=t210
JETSON_REL=r32.6
JETSON_BSP=jetson-210_linux_r32.6.1_aarch64.tbz2
JETSON_BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2

echo "Set target directories"

ROOT_DIR=/home/vqtrong/jetson-custom/rootfs
WORK_DIR=/home/vqtrong/jetson-custom/build

echo "Set system users"

JETSON_NAME=rover
JETSON_USR=jetson
JETSON_PWD=cccc

##########
echo "Prepare environment"

# 0.203373 http://mirror.coganng.com/ubuntu-ports
# 0.240577 http://ftp.lanet.kr/ubuntu-ports
# 0.264465 http://mirror.misakamikoto.network/ubuntu-ports
# 0.432951 http://ftp.harukasan.org/ubuntu-ports
# 0.572857 http://mirror.kumi.systems/ubuntu-ports
# 0.770989 http://ftp.tu-chemnitz.de/pub/linux/ubuntu-ports

# if [ -z "$REPO" ]
# then
#     REPO=$(./find_mirrors.sh arm64 bionic main speed | sort -k 1 | head -n 1 | awk '{print $2}')
# fi

mkdir -p $ROOT_DIR
mkdir -p $WORK_DIR

echo "ARCH = $ARCH"
echo "RELEASE = $RELEASE"
echo "REPO = $REPO"

echo "ROOT_DIR = $ROOT_DIR"
echo "WORK_DIR = $WORK_DIR"

echo "JETSON_BSP = $JETSON_BSP"
echo "JETSON_BSP_URL = $JETSON_BSP_URL"
