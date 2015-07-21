#!/bin/sh

. $(dirname $0)/functions.inc
base_directory

make linux-update-defconfig
make busybox-update-config
make uclibc-update-config 
