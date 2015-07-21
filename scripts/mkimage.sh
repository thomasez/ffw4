#!/bin/sh

. $(dirname $0)/functions.inc
base_directory

image_name=ffw4.img
loop_mount=loop

cd images 
# [ -d $TMP_FLOPPY_DIR ] &&  -r $(TMP_FLOPPY_DIR)
[ -f $image_name ] && rm $image_name
dd if=/dev/zero of=$image_name bs=1024 count=40000
mkdosfs $image_name
syslinux $image_name
mkdir -p $loop_mount
fusefat -o rw+ $image_name $loop_mount
cp bzImage $loop_mount/
cp ../ffw4-configs/* $loop_mount/.
# And then, any local configuration, for overriding the suplied one.
for file in ../local-configs/*
 do
  echo "Overriding default with " $file
  # Looking odd? I think it does at least. The reason for doing this is that
  # the loop mount creates the files as owned by root, and then I cannot copy
  # onto it without getting a "Permission denied". But deleteing and then
  # copying the file over, *that's* OK!
  rm $loop_mount/$(basename $file)
  cp $file $loop_mount/.
done
cp rootfs.cpio $loop_mount/initrd
fusermount -u $loop_mount

#cp -r $(BASE_DIR)/floppy/* $(TMP_FLOPPY_DIR)/.
