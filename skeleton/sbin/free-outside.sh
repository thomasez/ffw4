#!/bin/sh
# Very simple script to make sure we can renew IP address from DHCP.
# Made by; Jukka <user@domain.invalid>
# (Yeah, that's what the post said :=)

kill `pidof udhcpc` `pidof udhcpd`
rm /etc/outside.info

/etc/network.init
