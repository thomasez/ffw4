
macaddress=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))
echo $macaddress >> /tmp/arg1
qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -device e1000,netdev=net0,mac=$macaddress -netdev tap,id=net0,script=/tmp/qemu-ifup

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -net nic,model=virtio -net user

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -net none -device vfio-pci,host=0000:05:01.0

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -netdev eth3 -net virtio

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" 

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -netdev bridge,id=hn0 -device virtio-net-pci,netdev=hn0,id=nic1

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -net nic,model=virtio -net bridge

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append "root=/dev/sda init=/linuxrc" -net nic,model=virtio -net user

#qemu-system-i386 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append root=/dev/sda -net nic,model=virtio -net user

# qemu-system-x86_64 -M pc -kernel images/bzImage -drive file=images/rootfs.ext2,if=ide -append root=/dev/sda -net nic,model=virtio -net user

