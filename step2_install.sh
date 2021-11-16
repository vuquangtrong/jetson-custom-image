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

source ./step0_env.sh

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
echo "Setup locale"

chroot ${ROOT_DIR} locale-gen en_US
chroot ${ROOT_DIR} locale-gen en_US.UTF-8
chroot ${ROOT_DIR} update-locale LC_ALL=en_US.UTF-8

##########
echo "Add nameserver"

cat << EOF > ${ROOT_DIR}/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

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

chroot ${ROOT_DIR} apt update
chroot ${ROOT_DIR} apt upgrade -y

##########
echo "Install required packages"

# below packages are needed for installing Jetson packages in step #3
chroot ${ROOT_DIR} apt install -y --no-install-recommends \
    libasound2 \
    libcairo2 \
    libdatrie1 \
    libegl1 \
    libegl1-mesa \
    libevdev2 \
    libfontconfig1 \
    libgles2 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer-plugins-bad1.0-0 \
    libgtk-3-0 \
    libharfbuzz0b \
    libinput10 \
    libjpeg-turbo8 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpixman-1-0 \
    libpng16-16 \
    libunwind8 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1-mesa \
    libx11-6 \
    libxext6 \
    libxkbcommon0 \
    libxrender1 \
    python \
    python3 \

##########
echo "Install systen packages"

# below packages are needed for systen
chroot ${ROOT_DIR} apt install -y --no-install-recommends \
    wget \
    curl \
    linux-firmware \
    device-tree-compiler \
    network-manager \
    net-tools \
    wireless-tools \
    ssh \

##########
echo "Install X GUI"

chroot ${ROOT_DIR} apt install -y --no-install-recommends \
    xorg

if [ ! -z ${JETSON_DESKTOP} ]; then

    if [ ${JETSON_DESKTOP} == 'openbox' ]; then
        echo "Install Openbox"

        # minimal desktop, only greeter, no taskbar and background
        chroot ${ROOT_DIR} apt install -y --no-install-recommends \
            lightdm-gtk-greeter \
            lightdm \
            openbox \

    fi

    if [ ${JETSON_DESKTOP} == 'lxde' ]; then
        echo "Install LXDE core"

        # lxde with some components
        chroot ${ROOT_DIR} apt install -y --no-install-recommends \
            lightdm-gtk-greeter \
            lightdm \
            lxde-icon-theme \
            lxde-core \
            lxde-common \
            policykit-1 lxpolkit \
            lxsession-logout \
            gvfs-backends \

    fi

    if [ ${JETSON_DESKTOP} == 'xubuntu' ]; then
        echo "Install Xubuntu core"

        # Xubuntu, better than lxde
        chroot ${ROOT_DIR} apt install -y --no-install-recommends \
            xubuntu-core \

    fi

    if [ ${JETSON_DESKTOP} == 'ubuntu-mate' ]; then
        echo "Install Ubuntu Mate"

        # Ubuntu-Mate, similar to Ubuntu
        chroot ${ROOT_DIR} apt install -y --no-install-recommends \
            ubuntu-mate-core \

    fi

    # below packages are needed for desktop
    chroot ${ROOT_DIR} apt install -y --no-install-recommends \
        onboard \

fi

##########
echo "Install extra packages"

# below packages are needed for desktop
chroot ${ROOT_DIR} apt install -y --no-install-recommends \
    htop \
    nano \

##########
echo "Clean up"

chroot ${ROOT_DIR} apt autoremove -y
chroot ${ROOT_DIR} apt clean

##########
echo "Set up networks"

# ubuntu 18.04 us netplan, so it does not use /etc/network/interfaces anymore
cat << EOF > ${ROOT_DIR}/etc/netplan/01-netconf.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        eth0:
            optional: true
            dhcp4: true
    # add wifi setup information here ...
    wifis:
        wlan0:
            access-points:
                "${WIFI_SSID}":
                    password: "${WIFI_PASS}"
            dhcp4: true
            dhcp4-overrides:
                route-metric: 50
EOF

cat << EOF > ${ROOT_DIR}/etc/hostname
${JETSON_NAME}
EOF

##########
echo "Unmount dependency points"

for mnt in tmp dev/pts dev proc sys; do
    umount "${ROOT_DIR}/$mnt"
done
