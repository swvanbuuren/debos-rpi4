#!/bin/sh
UUID=$1
MOUNT_POINT=$2
mkdir -p $MOUNT_POINT
echo "UUID=${UUID} ${MOUNT_POINT}    ext4  defaults,auto,users,rw,nofail  0  0" >> /etc/fstab
