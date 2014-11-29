#!/bin/bash
set -e

export DISK_DEVICE="/dev/sda"
export DISK_BIOS="1"
export DISK_ROOT="2"
export DISK_MOUNT="/mnt"
export DISK_MOUNT_OPTIONS="-o noatime,autodefrag,compress=lzo,space_cache"
export DISK_FILESYSTEM="btrfs"

export HOSTNAME="arch"
export ROOT_PASSWORD="vagrant"
export TIMEZONE="Europe/London"
export LOCALE="en_GB.UTF-8"
export LANG="en_GB.UTF-8"
export KEYMAP="uk"
export PACKAGES="btrfs-progs sudo"


# helper functions
print() {
  echo "==> $@"
}

#
# Installation
#

install() {
  install_config
  install_disk
  install_bootstrap
  install_system
  install_finish
}

install_config() {
  config_keys
}

install_disk() {
  disk_zap
  disk_partitions
  disk_filesystems
  disk_mount
}

install_bootstrap() {
  bootstrap_pacman
  bootstrap_fstab
}

install_system() {
  system_copy
  system_run
}

install_finish() {
  finish_unmount
  finish_reboot
}

#
# Chroot
#

chroot() {
  chroot_hostname
  chroot_timezone
  chroot_locale
  chroot_vconsole
  chroot_packages
  chroot_mkinitcpio
  chroot_passwd
  chroot_bootloader
  chroot_network
  chroot_ssh
}

chroot_hostname() {
  hostname_file
}

chroot_timezone() {
  timezone_link
}

chroot_locale() {
  locale_uncomment
  locale_generate
  locale_lang
}

chroot_vconsole() {
  vconsole_keymap
}

chroot_packages() {
  packages_install
}

chroot_mkinitcpio() {
  mkinitcpio_generate
}

chroot_passwd() {
  passwd_setroot
}

chroot_bootloader() {
  grub_installpkg
  grub_install
  grub_mkconfig
}

chroot_network() {
  dhcp_enable
}

chroot_ssh() {
  ssh_install
  ssh_enable
}

#
# Configuration
#

config_keys() {
  print "setting console keymap to '${KEYMAP}'"
  loadkeys "${KEYMAP}"
}

#
# Disk
#

disk_zap() {
  print "zapping disk ${DISK_DEVICE}"
  sgdisk --zap-all "${DISK_DEVICE}"
}

disk_partitions() {
  print "creating partitions on ${DISK_DEVICE}"
  print "creating bios boot partition ${DISK_DEVICE}${DISK_BIOS}"
  sgdisk --new="${DISK_BIOS}":0:+100M --typecode=0:ef02  --attributes=0:set:2 "${DISK_DEVICE}"
  print "creating root partition ${DISK_DEVICE}${DISK_BIOS}"
  sgdisk --new="${DISK_ROOT}":0:0 --typecode=0:8300 "${DISK_DEVICE}"
}

disk_filesystems() {
  print "creating btrfs filesystem for root partition ${DISK_DEVICE}${DISK_ROOT}"
  mkfs."${DISK_FILESYSTEM}" "${DISK_DEVICE}${DISK_ROOT}"
}

disk_mount() {
  print "mounting filesystems on ${DISK_MOUNT}"
  mount ${DISK_MOUNT_OPTIONS} "${DISK_DEVICE}${DISK_ROOT}" "${DISK_MOUNT}"
}

#
# Bootstrap
#

bootstrap_pacman() {
  print "bootstrapping pacman on ${DISK_MOUNT}"
  pacstrap "${DISK_MOUNT}" base
}

bootstrap_fstab() {
  print "generating fstab for ${DISK_MOUNT}"
  genfstab -pU "${DISK_MOUNT}" >> "${DISK_MOUNT}/etc/fstab"
}

#
# System
#
system_copy() {
  print "copying installation script"
  cp "$0" "${DISK_MOUNT}/root/install.sh"
}

system_run() {
  print "running install script in chroot"
  arch-chroot /mnt bash /root/install.sh chroot
}

#
# Finish
#

finish_unmount() {
  print "unmounting destination filesystems"
  umount -R /mnt
}

finish_reboot() {
  print "installation finished. rebooting."
  reboot
}

#
# Hostname
#

hostname_file() {
  print "setting hostname to ${HOSTNAME}"
  echo "${HOSTNAME}" > /etc/hostname
}

#
# Timezone
#

timezone_link() {
  print "setting timezone to ${TIMEZONE}"
  ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
}

#
# Locale
#

locale_uncomment() {
  print "enabling locales for ${LOCALE}"
  sed -i "s/#\(${LOCALE}\)/\1/g" /etc/locale.gen
}

locale_generate() {
  print "generating locales"
  locale-gen
}

locale_lang() {
  print "setting language to ${LANG}"
  echo "LANG=${LANG}" > /etc/locale.conf
}

#
# Vconsole
#

vconsole_keymap() {
  print "setting console keymap to ${KEYMAP}"
  echo "KEYMAP=${KEYMAP}" >> /etc/vconsole.conf
}

#
# Packages
#

packages_install() {
  print "installing additional packages"
  pacman -Sy --noconfirm ${PACKAGES}
}

#
# Mkinitcpio
#

mkinitcpio_generate() {
  print "generating initcpio"
  mkinitcpio -p linux
}

#
# Password
#

passwd_setroot() {
  print "setting root password"
  echo "root:${ROOT_PASSWORD}" | chpasswd
}

#
# GRUB
#

grub_installpkg() {
  print "installing grub package"
  pacman -Sy --noconfirm grub
}

grub_install() {
  print "installing grub to disk ${DISK_DEVICE}"
  grub-install --target=i386-pc --recheck --debug "${DISK_DEVICE}"
}

grub_mkconfig() {
  print "generating grub configuration"
  grub-mkconfig -o /boot/grub/grub.cfg
}

#
# DHCP
#

dhcp_enable() {
  print "enabling dhcp"
  systemctl enable dhcpcd
}

#
# SSH
#

ssh_install() {
  print "installing ssh"
  pacman -Sy --noconfirm openssh
}

ssh_enable() {
  print "enabling ssh"
  systemctl enable sshd
}

#
# Ship it.
#
if [ "$1" == "chroot" ]; then
  set -u
  chroot
else
  set -u
  install
fi
