#!/bin/sh

. $(dirname $0)/functions.inc
base_directory

cd images
mkdir -p mnt
e2fsck -y rootfs.ext2
fuse-ext2 -o rw+ rootfs.ext2 mnt
cp -a ../skeleton/* mnt/.
fusermount -u mnt
