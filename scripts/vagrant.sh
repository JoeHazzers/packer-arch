#!/bin/bash
set -u
set -e

KEY_URL="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"

# user accound
useradd vagrant
echo 'vagrant:vagrant' | chpasswd

# sudo
echo "vagrant        ALL=(ALL)        NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 0400 /etc/sudoers.d/vagrant

# insecure vagrant ssh key
mkdir -pm 700 ~vagrant/.ssh
curl -Lo ~vagrant/.ssh/authorized_keys "${KEY_URL}"
chmod 0500 ~vagrant/.ssh/authorized_keys
chown -R vagrant ~vagrant/.ssh