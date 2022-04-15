#!/bin/bash

# Create a base custom image for jetson nano
# vuquangtrong@gmail.com
#
# step 3: apply JETSON_BSP

##########
echo "Check root permission"

if [ "x$(whoami)" != "xroot" ]; then
	echo "This script requires root privilege!!!"
	exit 1
fi

##########
echo "Get environment"

source ../jetson-custom-image/step0_env.sh

WORK_ROOT_DIR=${WORK_DIR}/Linux_for_Tegra/rootfs

##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Replace U-boot"
install -Dm644 u-boot.bin ${WORK_DIR}/Linux_for_Tegra/bootloader/t210ref/p3450-0000/u-boot.bin

echo "Replace Linux boot menu"
# note that flash.sh or make_image.sh will change add some extra boot commands based on the target boot device (SDcard/eMMC/etc.)
install -Dm644 extlinux.conf ${WORK_ROOT_DIR}/boot/extlinux/extlinux.conf

echo "Add overlay Device tree"
# this file is generated using sudo python /opt/nvidia/jetson-io/jetson-io.py on-board
install -Dm644 kernel_tegra210-p3448-0000-p3449-0000-b00-enable-spi1.dtb ${WORK_ROOT_DIR}/boot/kernel_tegra210-p3448-0000-p3449-0000-b00-enable-spi1.dtb

echo "Insert SPI driver"
# Jetpack 4.6 does not add driver automatically
cat << EOF >> ${WORK_ROOT_DIR}/etc/modules
spidev
EOF

echo "Disable console to take control ttyS0"
sed -i 's/console=ttyS0,115200n8//g' ${WORK_DIR}/Linux_for_Tegra/p3448-0000.conf.common

echo "Enable autologin"
cat << EOF > ${WORK_ROOT_DIR}/etc/lightdm/lightdm.conf.d/autologin.conf
[Seat:*]
autologin-guest=false
autologin-session=xubuntu
autologin-user=${JETSON_USR}
autologin-user-timeout=0
EOF

WIFI_SSID="SWEET HOME"
WIFI_PASS="conchocon"
cat << EOF > ${WORK_ROOT_DIR}/etc/netplan/01-netconf.yaml
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

echo "Enable color prompt for ${JETSON_USR} console"
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/g'  ${WORK_ROOT_DIR}/home/${JETSON_USR}/.bashrc

echo "Install qemu-aarch64-static"
# for next steps
install -Dm755 $(which qemu-aarch64-static) ${WORK_ROOT_DIR}/usr/bin/qemu-aarch64-static

if [[ ${JETSON_DESKTOP} == 'xubuntu' ]]; then
    echo "Add default XFCE settings"
    install -Dm644 xfce/xfce4-panel.xml ${WORK_ROOT_DIR}/home/${JETSON_USR}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    install -Dm644 xfce/xfce4-desktop.xml ${WORK_ROOT_DIR}/home/${JETSON_USR}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
fi

echo "Add default desktop icons"
rm -rf ${WORK_ROOT_DIR}/home/${JETSON_USR}/Desktop/*
install -Dm755 desktop/terminal.desktop ${WORK_ROOT_DIR}/home/${JETSON_USR}/Desktop/terminal.desktop

chroot ${WORK_ROOT_DIR} bash -c "chmod +x /home/${JETSON_USR}/Desktop/*.desktop"
chroot ${WORK_ROOT_DIR} bash -c "chown ${JETSON_USR}:${JETSON_USR} /home/${JETSON_USR}/Desktop/*.desktop"

echo "Start onboard"
install -Dm644 onboard/onboard-defaults.conf ${WORK_ROOT_DIR}/usr/share/onboard/onboard-defaults.conf
install -Dm644 onboard/onboard-autostart.desktop ${WORK_ROOT_DIR}/home/${JETSON_USR}/.config/autostart/onboard-autostart.desktop

echo "Set owner ${JETSON_USR} for .config"
chroot ${WORK_ROOT_DIR} bash -c "chown -R ${JETSON_USR}:${JETSON_USR} /home/${JETSON_USR}/.config"

# echo "Install extra packages"
# chroot ${WORK_ROOT_DIR} apt install -y --no-install-recommends \
    # xfce4-whiskermenu-plugin

echo "Disable nvgetty to take control ttyTHS1"
chroot ${WORK_ROOT_DIR} systemctl disable nvgetty

echo "Add user to groups"
chroot ${WORK_ROOT_DIR} usermod -a -G tty,dialout,gpio ${JETSON_USR}

echo "Clean up"
chroot ${WORK_ROOT_DIR} apt autoremove -y
chroot ${WORK_ROOT_DIR} apt clean

echo "Remove qemu-aarch64-static"
rm -f ${WORK_ROOT_DIR}/usr/bin/qemu-aarch64-static
