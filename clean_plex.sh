#!/bin/bash
chown -R *user*:*user* /home/*user*/torrents
chmod -R 777 /home/*user*/torrents
chown -R *user*:*user* /home/*user*/youtube
chmod -R 777 /home/*user*/youtube_Nathan
find . -name *.html -exec rm -rf "{}" \;
