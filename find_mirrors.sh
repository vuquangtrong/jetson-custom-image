#!/bin/bash

# thanks for Malte Skoruppa
# https://askubuntu.com/questions/428698/are-there-alternative-repositories-to-ports-ubuntu-com-for-arm

# URL of the Launchpad mirror list
MIRROR_LIST=https://launchpad.net/ubuntu/+archivemirrors

# Set to the architecture you're looking for (e.g., amd64, i386, arm64, armhf, armel, powerpc, ...).
# See https://wiki.ubuntu.com/UbuntuDevelopment/PackageArchive#Architectures
ARCH=$1

# Set to the Ubuntu distribution you need (e.g., precise, saucy, trusty, ...)
# See https://wiki.ubuntu.com/DevelopmentCodeNames
DIST=$2

# Set to the repository you're looking for (main, restricted, universe, multiverse)
# See https://help.ubuntu.com/community/Repositories/Ubuntu
REPO=$3

# Set flags to check speed of repo
SPDCHK=$4

# First, we retrieve the Launchpad mirror list, and obtain a newline-separated list of HTTP mirrors
mirrorList=()
for url in $(curl -s $MIRROR_LIST | grep -Po 'http://.*(?=/">http</a>)'); do
  # if [[ $url == *".vn"* ]]; then
    # echo $url
    mirrorList+=( "$url" )
  # fi
done


# Second, we try to connect to the site at `$url/dists/$DIST/$REPO/binary-$ARCH/`
for url in "${mirrorList[@]}"; do
  (
    rurl=$url/dists/$DIST/$REPO/binary-$ARCH/
    # If you like some output while the script is running (feel free to comment out the following line)
    # echo "Processing $rurl"
    # retrieve the header; check if status code is 200
    if curl --connect-timeout 5 -s --head $rurl | head -n 1 | grep -q 'HTTP/[12].*200';
    then
        if [ $SPDCHK = "speed" ]
        then
          echo $(curl -s -w '%{time_total}\n' -o /dev/null $rurl) "$url"
        else
          echo "$url"
        fi
    fi
  ) &
done

wait

echo "Search done!"
