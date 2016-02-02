#!/bin/bash
pacman -Sy --noconfirm virtualbox-guest-utils-nox virtualbox-guest-modules

cat << EOF > /etc/modules-load.d/virtualbox.conf
vboxguest
vboxsf
vboxvideo
EOF
