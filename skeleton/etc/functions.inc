
# $Id: functions.inc,v 1.6 2005/08/13 10:02:16 thomasez Exp $

# Define a function to strip CRs from files and chmod if desired
stripcr () {
	#[ -r $1 ] && { echo stripcr $1 $2; tr -d '\r' < $1 > $2; }
	#[ -n $3 ] && { echo chmod $3 $2; chmod $3 $2; }
	[ -r $1 ] && { echo -n $1 ; tr -d '\r' < $1 > $2; echo " stripped"; }
	#echo -n "X$3"
	#echo "X"
	[ -n "$3" ] && { chmod $3 $2 ; echo "$1 chmoded"; }
}

load_fsmod () {
       case $1 in
       # /dev/hd*)
       /dev/discs* | /dev/ide* | /dev/cdrom*)
               insmod cdrom
               insmod ide-core
               insmod ide-detect
               insmod ide-cd
               insmod ide-disk
               insmod scsi_mod
               insmod libata
               insmod ahci
               insmod sata_nv
               insmod sata_promise
               insmod sata_sil
               insmod sata_sis
               insmod sata_svw
               insmod sata_sx4
               insmod sata_uli
               insmod sata_via
               insmod sata_vsc
               ;;
       /dev/scsi* )
               insmod cdrom
               insmod ide-core
               insmod ide-detect
               insmod ide-cd
               insmod ide-disk
               insmod scsi_mod
               insmod sd_mod
               insmod usbcore
               insmod uhci
               insmod usb-uhci
               insmod usb-ohci
               insmod ehci-hcd
               modprobe usb-storage
               # It needs to initialize itself.
               sleep 10
               ;;
       esac
       case $2 in
       vfat)
               echo vfat support is builtin
               ;;
       iso9660)
               insmod zlib_inflate
               insmod isofs
               ;;
       esac
}

bool_value () {
	case "$1" in

	[Tt]|true|[Yy]|yes)
		return 0
		;;
	*)
		return 1
		;;
	esac
	return 1
}

count () {
	LO=$1;HI=$2
	while [ $LO -le $HI ]
	    do
	    echo -n $LO " "
	    LO=`expr $LO + 1`
	    done
}

configure_interface () {
	if=$1         
	if echo $if | grep -q '[a-z]\{1,\}[0-9]\{1,\}\.[0-9]\{1,\}'
	  then                                             
	    vconfig add `echo $if | sed -e 's/\./ /'`
	fi
	ifconfig $*
}                

