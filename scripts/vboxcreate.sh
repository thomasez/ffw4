#!/bin/sh

. $(dirname $0)/functions.inc
base_directory

vm_name=${1?vm_name name needed}
image=${2:=rootfs.img}

cd images
rm -f $vm_name.vdi

VBoxManage createvm --name "$vm_name" --register
# VBoxManage modifyvm "$vm_name" --memory 128 --acpi on --boot1 sda --nic1 bridged --bridgeadapter1 eth0
VBoxManage modifyvm "$vm_name" --memory 64 --acpi on --boot1 sda 
VBoxManage modifyvm "$vm_name" --nic1 bridged --bridgeadapter1=eth0 --nictype1 Am79C973 --cableconnected1 on
VBoxManage modifyvm "$vm_name" --nic2 bridged --bridgeadapter2=eth0 --nictype2 Am79C973 --cableconnected2 on

VBoxManage convertfromraw $image $vm_name.vdi --format=vdi
VBoxManage storagectl "$vm_name" --name "IDE Controller" --add ide
VBoxManage storageattach "$vm_name" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium $vm_name.vdi


# VBoxManage createhd --filename $vm_name.vdi --size 10000
# VBoxManage storageattach "" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /tmp/$vm_name

exit;

# Mounting a vdi:
modprobe nbd
qemu-nbd -c /dev/nbd0 <vdi-file>
mount /dev/nbd0p1 /mnt
# unmount
umount /mnt
qemu-nbd -d /dev/nbd0
