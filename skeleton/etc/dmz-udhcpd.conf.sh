#!/bin/sh

# $Id:$

. /etc/ffw4.conf
. /etc/dmz.info

if [ "$DMZ_DOMAIN" ]
  then
    DMZ_DHCPDDOMAIN=$DMZ_DOMAIN
  else
    DMZ_DHCPDDOMAIN=`for DOMAINS in $(grep search /etc/resolv.conf | sed 's/^search//'); do echo $DOMAINS; break; done`
fi

# Just a default to be sure we have something.
[ -z "$DMZ_DHCPDDOMAIN" ] && DMZ_DHCPDDOMAIN=dmz.floppyfwsecured.local

echo "DMZ_DOMAIN:$DMZ_DHCPDDOMAIN" >> $DEBUG_LOG

cat > /etc/dmz-udhcpd.conf <<EOF
interface       $DMZ_DEVICE
start           $DMZ_DHCP_RANGE_START
end             $DMZ_DHCP_RANGE_END
# max_leases	103
lease_file      /var/state/dmz-udhcpd.leases
pidfile         /var/run/dmz-udhcpd.pid
option          dns             $DMZ_IP
option          subnet          $DMZ_NETMASK
option          broadcast       $DMZ_BROADCAST
option          router          $DMZ_IP
option          domain          $DMZ_DHCPDDOMAIN
option          lease           864000                                   
$OPS
EOF

# Adding the /etc/dmz-ethers file:
# I'll use the same file for both. shouldn't matter.
[ -f /etc/dmz-ethers ] && sed -e '/^#/d;/^$/d;s/^/static_lease /' /etc/dmz-ethers >> /etc/dmz-udhcpd.conf
