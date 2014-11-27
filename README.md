# packer-arch

This provides a quick and fast (and dirty, depending on your perspective)
image for 64-bit Arch Linux.

By default the packer build template provisions the instance with vagrant's
insecure SSH key and adds a `vagrant` user with the password `vagrant` and
password-less sudo privileges. The root password is also set to `vagrant`.

The default builder is `virtualbox-iso` and as such a shell provisioner has
been included to install VirtualBox's Guest Additions software (along with
dependencies and kernel modules) to enable better integration with the host
operating system (and most notably vagrant).


## usage
To build the vagrant box:

    $ packer build arch64.json

## requirements

- [Packer](https://packer.io/)
- [VirtualBox](https://www.virtualbox.org/)
