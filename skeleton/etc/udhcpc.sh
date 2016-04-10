#!/bin/sh

# $Id$

#
# Grabbing the config.
#
. /etc/ffw4.conf

#
# Grabbing the function library.
#
. /etc/functions.inc

HARGS=
[ "$USER_IDENT" != "" ] && HARGS="-H $USER_IDENT"

if $(bool_value "$DHCP_USE_LAST_ADDR" && [ -f /etc/dhcp.addr ])
  then
    # We're going to need an address
    LAST_DHCP_ADDR=$(cat /etc/dhcp.addr | tr -d '\n' | tr -d '\r')
    # if [ -n "$LAST_DHCP_ADDR" ]
    if [ "$LAST_DHCP_ADDR" != "" ]
      then
        echo "Gonna ask for $LAST_DHCP_ADDR"
        if udhcpc -t 3 -r $LAST_DHCP_ADDR -n -s /etc/udhcpcrenew.sh $HARGS -i $OUTSIDE_DEV
          then
	       . /etc/outside.info
           echo $OUTSIDE_IP > /etc/dhcp.addr  2> /dev/null
           # We're happy and can exit.
           exit 0
        fi
    fi
fi

#
# OK, either we did not have an existing address or we did not get it.
#
if udhcpc -n -s /etc/udhcpcrenew.sh $HARGS -i $OUTSIDE_DEV
  then
    if $(bool_value "$DHCP_USE_LAST_ADDR" && touch /etc/dhcp.addr 2> /dev/null)
      then
        . /etc/outside.info
        echo $OUTSIDE_IP > /etc/dhcp.addr  2> /dev/null
    fi
    exit 0
  else
    exit 1
fi
