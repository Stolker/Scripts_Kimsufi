#!/bin/bash

# Here specify the apps you want into the enviroment
APPS="/usr/bin/env /usr/bin/wget /usr/bin/clear /usr/bin/host /bin/sh /bin/grep /bin/cat /usr/bin/vi /bin/gzip /bin/gunzip /usr/bin/less /usr/bin/tail /usr/bin/nslookup /bin/bash /bin/ls /bin/mkdir /bin/mv /bin/pwd /bin/rm /bin/su /usr/bin/id /usr/bin/ssh /usr/bin/sudo /bin/ping /usr/bin/dircolors /usr/bin/screen /bin/ps /bin/uname /bin/sed"

# Sanity check
if [ -z "$1" ]; then
echo "    Usage: $0 username"
exit
fi

# Obtain username and HomeDir
CHROOT_USERNAME=$1
HOMEDIR=`grep /etc/passwd -e "^$CHROOT_USERNAME:"  | cut -d':' -f 6`
cd $HOMEDIR

mkdir etc bin lib usr usr/bin dev
# We need as many tty's as consoles
/bin/mknod -m 666 dev/tty  c 5 0
/bin/mknod -m 644 dev/tty1 c 4 1
/bin/mknod -m 644 dev/tty2 c 4 2
/bin/mknod -m 644 dev/tty3 c 4 3
/bin/mknod -m 644 dev/tty4 c 4 4
/bin/mknod -m 644 dev/tty5 c 4 5
/bin/mknod -m 644 dev/tty6 c 4 6
#and pts
mkdir dev/pts
/bin/mknod -m 666 dev/pts/0  c 136 0
/bin/mknod -m 666 dev/pts/1  c 136 1
# Some special nodes, just for fun
/bin/mknod -m 444 dev/urandom c 1 9
/bin/mknod -m 666 dev/zero c 1 5
/bin/mknod -m 666 dev/null c 1 3

# Create short version to /usr/bin/groups
# On some system it requires /bin/sh, generally unnessesary in a chroot cage

echo "#!/bin/bash" > usr/bin/groups
echo "id -Gn" >> usr/bin/groups

# Add some users to ./etc/paswd
grep /etc/passwd -e "^root:" -e "^$CHROOT_USERNAME:" > etc/passwd
grep /etc/group -e "^root" -e "^$CHROOT_USERNAME:" > etc/group

#Settings prompt
cp /etc/profile etc/profile
cp -R /etc/bash* etc
echo "export HOME=/" >> etc/profile

for prog in $APPS;  do
    cp $prog ./$prog
    # obtain a list of related libraries
    ldd $prog > /dev/null
    if [ "$?" = 0 ] ; then
    LIBS=`ldd $prog`
    for l in $LIBS; do
        if [ -f $l ]; then
            mkdir -p .`dirname $l` > /dev/null 2>&1
            cp $l ./$l
        fi
    done
    fi
done

# For strange reason, these 3 libraries are not in the ldd output, but without
# them some stuff will not work, like usr/bin/groups
cp /lib/x86_64-linux-gnu/libnss_compat.so.2 /lib/x86_64-linux-gnu/libnsl.so.1 /lib/x86_64-linux-gnu/libnss_files.so.2 /lib64/ld-linux-x86-64.so.2  /lib/x86_64-linux-gnu/libresolv.so.2 /lib/x86_64-linux-gnu/libnss_dns.so.2 ./lib/
chmod 755 usr/bin/groups

cp /etc/host.conf ./etc/
cp /etc/hosts ./etc/
cp /etc/nsswitch.conf ./etc/
cp /etc/localtime ./etc/
cp /etc/resolv.conf ./etc/
cp /etc/services ./etc/
cp /etc/protocols ./etc/
mkdir ./etc/terminfo/
cp -R /etc/terminfo/* ./etc/terminfo/

find . -type d -exec chown -R root:root {} \;
