#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 2: customize rootfs

##########
echo "Get environment"

. ./step0_env.sh

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Unmount dependency points"

for mnt in dev/pts dev proc sys; do
  umount "${ROOT_DIR}/$mnt"
done
