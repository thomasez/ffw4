ffw4
====

Homepage: http://www.zelow.no/floppyfw

The good old floppyfw, now generation 4.

But what will this be? It's still <a href="http://buildroot.org">Buildroot</a> based but this time without a devkit. You just download / clone ffw4 and buildroot, pick the defconfig you want (right now it's ffw4-vm for virtual machines and ffw4-pi for RaspberryPi.) and start making.

I will provide images aswell, and those will of course be found here. Images in a floppy? Sorry, no. I am pretty sure that's practically impossible, just the compiled kernel for vmfw is 1.9MB

So, what's the main difference from floppyfw-3.0?

 * It does not fit on a floppy. It has grown way beyond my liking and the base image is now 40MB.
 * No web server, no GUI. Just edit files and run along.
 * /etc/init.d/ - initscripts. But still very simple and main config is done in ff2.conf (which was named config before)
 * Newest possible released Linux kernel (3.17 when this was written.
 * No iptables,but instead I've jumped directly to <a href="http://www.netfilter.org/projects/nftables/index.html">nftables</a>
 * Can be compiled and run on anything that Buildroot can be persuaded to build for. Right now it's RaspberryPi, but I also want to run it on one or more Mikrotik routers.

