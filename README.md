# Debos recipe for Raspberry Pi 4B

This repository contains a [debos](https://github.com/go-debos/debos) recipe for
the [Raspberry Pi 4 Model
B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/).

## How to build

Run the following command to build the image from the Debos recipe:

```bash
debos -m 8192MB -b kvm debian-rpi4.yaml
```

## Test with Qemu

The following instructions show, how to test the image in a Qemu environment.

### Prerequisite

The instruction are valid for a recent Debian system (it was tested on Bullseye).

A series of package is required to be installed, using the following command:

```bash
apt install libguestfs-tools libguestfs-tools qemu-system-arm qemu-utils
```

### Instructions

To test the image in Qemu environment, it is recommended to use the following bash script `image_run`, where `<kernel-version>` is to be replaced with the actual used kernel version (e.g. `6.1.0-15`):

```bash
#!/bin/bash
KERNEL_VERSION="<kernel-version>"
INITRD_FILE="initrd.img-${KERNEL_VERSION}-arm64"
VMLINUZ_FILE="vmlinuz-${KERNEL_VERSION}-arm64"

if [ ! -f "$INITRD_FILE" ]; then
    virt-copy-out -a $1 "/boot/$INITRD_FILE" .
fi

if [ ! -f "$VMLINUZ_FILE" ]; then
    virt-copy-out -a $1 "/boot/$VMLINUZ_FILE" .
fi

qemu-system-aarch64 \
    -m 2048 \
    -cpu cortex-a57 \
    -smp 2 \
    -M virt \
    -kernel $VMLINUZ_FILE \
    -initrd $INITRD_FILE \
    -append 'root=/dev/vda2' \
    -drive if=none,file=$1,format=qcow2,id=hd \
    -device virtio-blk-pci,drive=hd \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -nographic
```

Make the script executable (`chmod +x image_run`) and use it with the following
command

```bash
./image_run debian-rpi4.qcow2
```

## Notice

This debos recipe is based on the [rpi64
recipe](https://github.com/go-debos/debos-recipes/tree/main/rpi64) of
[debos-recipes](https://github.com/go-debos/debos-recipes). It contains a
modified, updated [recipe file](debian-rpi4.yaml) and adopts some of the
[overlays](overlays) and [scripts](scripts) from the
[original](https://github.com/go-debos/debos-recipes).

## License

To remain inline with the [original
recipe](https://github.com/go-debos/debos-recipes) on which this recipe is
based, the same Apache style license applies to this recipe. See the
[LICENSE](LICENSE) file for more details.
