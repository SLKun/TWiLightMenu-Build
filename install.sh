#!/usr/bin/bash

TWiLightMenu_URL="git@github.com:Summerslyb/TWiLightMenu.git"
NDSBootstrap_URL="git@github.com:Summerslyb/nds-bootstrap.git"
GBARunner2_URL="git@github.com:Summerslyb/GBARunner2.git"

md5(){
    md5sum $1 | awk '{print $1}'
}

# Install DevkitPro
echo "Installing DevkitPro..."
if [ ! -d "/opt/devkitpro" ]; then
    pacman-key --recv F7FD5492264BB9D0
    pacman-key --lsign F7FD5492264BB9D0
    pacman -U https://downloads.devkitpro.org/devkitpro-keyring-r1.787e015-2-any.pkg.tar.xz
    echo "[dkp-libs]" >> /etc/pacman.conf
    echo "Server = https://downloads.devkitpro.org/packages" >> /etc/pacman.conf
    echo "[dkp-linux]" >> /etc/pacman.conf
    echo "Server = https://downloads.devkitpro.org/packages/linux" >> /etc/pacman.conf
    pacman -Syu nds-dev --noconfirm
fi

# Prepare TWiLightMenu
echo "Prepare TWiLightMenu..."
if [ ! -d "TWiLightMenu" ]; then
    git clone ${TWiLightMenu_URL}
fi

# Install Python2
if [ -z $(pacman -Qq | grep python2) ]; then
    pacman -S python2 --noconfirm
fi

# Replace libmm7.a
Local_MD5=$(md5 TWiLightMenu/libmm7.a)
Devkit_MD5=$(md5 /opt/devkitpro/libnds/lib/libmm7.a)
if [ $Local_MD5 != $Devkit_MD5 ]; then
    cp /opt/devkitpro/libnds/lib/libmm7.a /opt/devkitpro/libnds/lib/libmm7.a.bak
    cp TWiLightMenu/libmm7.a /opt/devkitpro/libnds/lib/libmm7.a
fi

# Prepare nds-bootstrap
echo "Prepare NDS-Bootstrap..."
if [ ! -d "nds-bootstrap" ]; then
    git clone ${NDSBootstrap_URL}
fi

# Install lzss
if [ ! -f "/opt/devkitpro/tools/bin/lzss" ]; then
    wget https://cdn.discordapp.com/attachments/283769550611152897/615767904926826498/lzss -O /opt/devkitpro/tools/bin/lzss
    chmod +x /opt/devkitpro/tools/bin/lzss
fi

# Prepare GBARunner2
echo "Prepare GBARunner2..."
if [ ! -d "GBARunner2" ]; then
    git clone ${GBARunner2_URL}
fi