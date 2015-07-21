#!/bin/sh
#	vim "set ts=4"

#	File:		udhcpcrenew.sh script
#	Author:		Not named in original file
#	Hacked by:	Jim Murphy
#	$Id: udhcpcrenew.sh,v 1.11 2005/10/16 11:38:27 thomasez Exp $

#	Assumption:	Your ISP better supply the "ip" and "subnet" 
#			variables or all of this is for not. 
#			 "router", "dns", "lease" should be there also
#			along with a few others.

# Thomas has to check if the script keeps the address even if the 
# client can't reach the dhcp server for renew.

. /etc/functions.inc

# (Dis)Allow additional info to be printed, etc...
DEBUG=0

#
# One of 4 possible states(deconfig, bound, renew or nak).
#
STATE=$1

DECONFIG_FILE=/etc/DECONFIG_YES

RESOLVF=/etc/resolv.conf

old_search=""
old_dns=""
new_search=""

get_old_search_name ()
{
	old_search=`grep '^search' $RESOLVF`
	old_search=${old_search##* }
}

get_old_dns_addrs ()
{
	for line in `grep '^nameserver' $RESOLVF`
	do
		[ "$line" != nameserver ] && {
			[ -z "$old_dns" ] \
				&& old_dns=$line \
				|| old_dns="$old_dns $line"
		}
	done

}

deconfigure ()
{
	configure_interface $interface 0.0.0.0
	touch $DECONFIG_FILE
}

do_nak ()
{
	# If needed.
	# Anyone know or any nak code?

	:

}

setup_net ()
{
	echo "DHCP IP (re)newal. Debug: $STATE" > $DEBUG_LOG
	echo "0" > /proc/sys/net/ipv4/ip_forward

	# Set up for ifconfig command
	[ -n "$broadcast" ] && BCAST="broadcast $broadcast"
	[ -n "$subnet" ] && NMASK="netmask $subnet"

	echo "Debug: ifconfig $interface $ip $BCAST $NMASK" >> $DEBUG_LOG
	echo "Debug: router: $router dns: $dns domain: $domain" >> $DEBUG_LOG

	configure_interface $interface $ip $BCAST $NMASK

	if [ -n "$router" ]
	then
		echo "deleting routes"
		while route del default gw 0.0.0.0 dev $interface 2> /dev/null
		do :
		done

		for i in $router
		do
			route add default gw $i dev $interface
		done
	fi

	echo "DHCP successfully (re)configured:"
	echo "Your address is $ip"
	echo "The default gateway is $router"
}

setup_filter ()
{
	#
	# Creating a new /etc/outside.info
	#
	cat > /etc/outside.info <<EOF
# Created by $0
OUTSIDE_DEVICE=$interface
OUTSIDE_IP=$ip
OUTSIDE_NETMASK=$subnet
OUTSIDE_NETWORK=$network
OUTSIDE_BROADCAST=$broadcast
OUTSIDE_GATEWAY=$router
EOF

	echo "$0: setting up firewall rules:"
	/etc/firewall.init

	echo "firewall.init was run"

	if bool_value "$USE_SYSLOG"
	then
		logger "firewall.init was run."
	fi
}

# Do renew scripts
do_renew_scripts () {
	for i in /etc/renew-*
	do
		if [ -f $i ]
		then
			sh $i $1
		fi
	done
}

record_env ()
{
	#
	# This will only output data if DEBUG is set TRUE(0).
	#
	[ "$DEBUG" = "$TRUE" ]  \
		&& {
			env > /foo
			set > /foo2
		}
}

#
# Source the config file
#
. /etc/ffw4.conf


#
# If STATE is equal to deconfig, then take down the interface.
# Deconfig, at least on my system, only occurs once.  After that I see one
# bound state, and the rest have all been the renew state.
#
[ "$STATE" = deconfig ] && {
	echo "deconfiguring interface."
	deconfigure
	exit
}

#
# Need to research and adjust as needed for the "nak" state.
#
[ "$STATE" = nak ] && {
	do_nak
	echo ""
	echo "Anyone know what to do with the \"nak\" that was just received?"
	echo "Exiting $0 script!"
	echo ""
	exit
}

#
# We are creating a new one.(old comment)
# Not always needed - verify changes before doing anything.
# If no outside.info, set defaults, used for verification of changes.
#
[ -f /etc/outside.info ] \
	&& . /etc/outside.info \
	|| {
		OUTSIDE_BROADCAST=X
		OUTSIDE_IP=X
		OUTSIDE_DEVICE=X
		OUTSIDE_NETMASK=X
		OUTSIDE_NETWORK=X
		OUTSIDE_GATEWAY=X
	}

#
# Moved cidr stuff here instead of in firewall.ini(my system)
# to compensate for what I originally thought was a bug in udhcpcd
# with 1.9.21(first time noticed).
# I couldn't use udhcpcd prior to this because of another bug with
# udhcpcd.  Actually turns out that some ISPs(including my own) do
# not always return all requested data. ;-((
#
# Now set up to use BB_CIDR or original cidr command.  2.0.x and
# above should be able to take advantage of BB_CIDR, where older
# versions can still use the original command.
# 
# No, it's ipcalc this time. Thomas.
#
[ -z "$network" ] && {
	[ -n "$ip" ] && [ -n "$subnet" ] && {
		eval `ipcalc -n $ip $subnet`
		network=$NETWORK
		unset NETWORK
	}
}

[ -z "$broadcast" ] && {
	[ -n "$ip" ] && [ -n "$subnet" ] && {
		eval `ipcalc -b $ip $subnet`
		broadcast=$BROADCAST
		unset BROADCAST
	}
}

#
# We need $dns to be present for it to work at all
#
[ -f "$RESOLVF" ] \
	&& {
		# Get the old info just in case
		get_old_search_name
		get_old_dns_addrs
	} \
	|| {
		old_search="NoDomain"
		old_dns="NoDNS"
	}

# Domain is obsolete, using search instead. Please refer to the
# resolv.conf man pages.
#
# The difference between DOMAIN and domain is that "DOMAIN" is set in 
# the floppyfw config file while "domain" is received from the external
# DHCP server.
#
# Search - How should it be set?
#	1: If DOMAIN is set in the config file and domain is set from
#	   the external DHCP server, use both.
# 	2: If DOMAIN is set in the config file and domain is not set
#	   from the external DHCP server, use only DOMAIN.
#	3: If DOMAIN is not set in the config file but is set from
#	   the external DHCP server, use domain.
#	4: If DOMAIN is not set in the config file and the external
#	   DHCP server does not supply one, use "floppyfwsecured.not".

[ ! -z "$DOMAIN" ] && { new_search="$DOMAIN"; }
[ ! -z "$domain" ] && { [ -z "$new_search" ] && new_search=$domain || new_search="$new_search $domain"; }
[ -z "$new_search" ] && { new_search="floppyfwsecured.not"; }

# Name server handling: 
# First the (optional) OUTSIDE_NAMESERVERS, then whatever 
# came from the DHCP server.
# (Hmmm, I kinda wonder why we just don't write a new resolv.conf each time.
#  It's probably some good reason for it..)

dns="$OUTSIDE_NAMESERVERS $dns"

[ "$dns" != "$old_dns" \
	-o "$new_search" != "$old_search" \
	-o ! -f "$RESOLVF" ] && {
	cat > $RESOLVF <<EOF
# Created by $0
search ${new_search}
EOF

	echo "Debug: dns: $dns" >> $DEBUG_LOG
	for i in $dns
	do
		echo "nameserver $i"
	done >> $RESOLVF

	chmod 644 $RESOLVF
}

#
# All things being equal, no need to go through the setup again.
#
[ "$subnet" = "$OUTSIDE_NETMASK" \
	-a "$interface" = "$OUTSIDE_DEVICE" \
	-a "$router" = "$OUTSIDE_GATEWAY" \
	-a "$broadcast" = "$OUTSIDE_BROADCAST" \
	-a "$network" = "$OUTSIDE_NETWORK" \
	-a "$ip" = "$OUTSIDE_IP" \
	-a ! -f "$DECONFIG_FILE" ] \
		&& {
			logger "Firewall.init will NOT run, Nothing changed."
			record_env
			exit 0
		} \
		|| {
			logger "Firewall.init will be run, Something changed."
			setup_net
			setup_filter
			do_renew_scripts $STATE
			rm -f $DECONFIG_FILE
			record_env
		}

exit 0

 # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #
 #	End of Main Section
 # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #  # -- #
 
