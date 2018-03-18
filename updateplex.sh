#!/bin/bash
cd /tmp
rm plexmediaserver_*.deb
/opt/plexupdate/plexupdate.sh
file=$(find /tmp -name "*plexmediaserver_*.deb" | wc -l)
if [ $file -eq 1 ]; then
service plexmediaserver stop
dpkg -i plexmediaserver_*.deb
service plexmediaserver start
rm plexmediaserver_*.deb
fi
cd /var/www/rutorrent && git pull origin master
