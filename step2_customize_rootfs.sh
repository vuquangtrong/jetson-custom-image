#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 2: customize rootfs

./step2a_install.sh # run installation
ret=$? # return 0 if no error
if [ $ret -ne 0 ]; then
    ./step2b_cleanup.sh # clean up if something is wrong
fi
