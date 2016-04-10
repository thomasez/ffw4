#!/bin/sh
#
# This shell script converts /etc/ethers to preassigned leases in
# /var/udhcpd.leases. It's used to reserve IPs for certain hosts
# by making udhcpd think it has already given a lease to the host.
# Run this before starting udhcpd.
#
# The input format is:
# mac-address   ip-address
#
# Comment lines and blank lines are ignored
#
while m=i=j= && read m i j
do
        case "$m" in
        ""|\#*) continue
                ;;
        esac
        case "$i" in
        "")     continue
                ;;
        esac
        a=$(echo $m | sed -e 's/:/ 0x/g' -e 's/^/0x/')
        b=$(echo $i | sed 's/\./ /g')
        s=$(printf '\\%03o\\%03o\\%03o\\%03o\\%03o\\%03o\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\%03o\\%03o\\%03o\\%03o\\177\\\
377\\377\\177' $a $b)
        echo -ne $s 1>&4
done < /etc/ethers 4> /var/state/udhcpd.leases
