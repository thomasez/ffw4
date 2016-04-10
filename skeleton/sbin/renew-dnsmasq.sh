#!/bin/sh

. /etc/vmfw.conf
. /etc/functions.inc

bool_value "$DNSMASQ" || bool_value "$DHCP_SERVER" && {
	# Find out if dnsmasq is running
	p=`pidof dnsmasq`

	[ $p ] && kill -HUP $p
}
