#!/bin/bash
if [ ! -x ./xmlrpc2scgi.py ]
then
wget https://raw.githubusercontent.com/rakshasa/rtorrent-vagrant/master/scripts/xmlrpc2scgi.py &> /dev/null
chmod 0755 xmlrpc2scgi.py
fi
status=$(./xmlrpc2scgi.py -p scgi://127.0.0.1:5001 get_ip 2>/dev/null| grep -c "0.0.0.0")
if [ $status -eq 0 ]
then
echo "$(date +"%D %T") : WARNING - rTorrent is stopping, please restart">>/var/log/rTorrent_monitor.log
service patate-rtorrent restart
elif [ $status -eq 1 ]
then
echo "$(date +"%D %T") : rTorrent is running">>/var/log/rTorrent_monitor.log
else
echo "$(date +"%D %T") : ??????? I don't know">>/var/log/rTorrent_monitor.log
fi
