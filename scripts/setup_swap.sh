#!/bin/sh

fallocate -l 100MB /swapfile
chmod 600 /swapfile
mkswap /swapfile

if [ `grep -c swapfile /etc/fstab` -eq 0 ]
then
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
fi
