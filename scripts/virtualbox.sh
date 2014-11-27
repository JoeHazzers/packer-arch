#!/bin/bash
pacman -Sy --noconfirm virtualbox-guest-utils

cat << EOF > /etc/modules-load.d/virtualbox.conf
vboxguest
vboxsf
vboxvideo
EOF
