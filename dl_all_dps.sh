#!/bin/bash
#
# dl_all_dps.sh 
#
# Downloads all the torrents for the current lastest releases of driver packs 
# for all Windows operating systemss and all their architectures.
# TLDR: Downloads all available driver packs
#
# &copy; Michael Craze -- http://projectcraze.us.to

for x in `lynx -dump http://driverpacks.net/driverpacks/latest | grep "http:\/\/driverpacks\.net\/driverpacks\/windows\/" | awk '{print $2;}'`; do
	#/driverpacks/windows/7/x86/monitors/10.01/download/torrent
	echo "Getting: $x";

	# This should work, but it doesn't - couldn't figure out why so rewrote script in perl
	#lynx -dump "$x" | grep "\/download\/torrent" | awk '{print $2}' | wget -i -
	lynx -force_html -dump "$x" | grep "\/download\/torrent" | awk '{print $2}'
done
