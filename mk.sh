#!/bin/sh

#
# This is cheating. I just couldn't get the ffw4-targets into the main Makefile.
#

if [ -n "$VARIANT" ]
 then
  make VARIANT=$VARIANT --makefile=Makefile.ffw "$@"
 else
  make --makefile=Makefile.ffw "$@"
fi

