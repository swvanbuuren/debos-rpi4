# Debos recipe for Raspberry Pi 4B

This repository contains a [debos](https://github.com/go-debos/debos) recipe for
the [Raspberry Pi 4 Model
B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/).

## How to build

Follow these instructions to build the image.

## First build

In order to save build time, the `base-pack.yaml` recipe is prebuilt and stored
in a compressed archive. By default, the standard build is configured to extract and use build results from this archive. This is controlled using the variable `unpack`.

To build the image the first time, using the recipe `base-pack.yaml` instead of
the prebuilt archive, run the following command:

```bash
debos -m 8192MB -b kvm -t unpack:false debian-rpi4.yaml
```

This will also store the results from the recipe `base-pack.yaml` and replace
any previously generated archive. If the `base-pack.yaml` recipe has been
changed, you also want build the image using this command.

## Normal build

If you already have generated the `base-pack` archive and the `base-pack.yaml`
recipe hasn't been changed, you can build the image using:

```bash
debos -m 8192MB -b kvm debian-rpi4.yaml
```

## Test with Qemu

The following instructions show, how to test the image in a Qemu environment.

### Prerequisite

The instruction are valid for a recent Debian system (it was tested on Bullseye).

A series of package is required to be installed, using the following command:

```bash
sudo apt install libguestfs-tools qemu-system-arm qemu-utils
```

### Instructions

To test the image in a Qemu environment, it is recommended to use the following
bash script `image_run`:

```bash
#!/bin/bash
# Find boot artifacts
for basename in "vmlinuz" "initrd.img"; do
    if [ -f "$basename" ]; then continue; fi
    fpath=$(virt-ls -a "$1" /boot | grep -E "^$basename-[[:digit:]]" | sort -r | head -n 1)
    echo "Found $fpath!"
    virt-copy-out -a $1 "/boot/$fpath" .
    mv $fpath $basename
done
# Launch Qemu
qemu-system-aarch64 \
    -m 2048 \
    -cpu cortex-a57 \
    -smp 2 \
    -M virt \
    -kernel vmlinuz \
    -initrd initrd.img \
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

You can terminate the Qemu environment by pressing <kbd>Ctrl</kbd> +
<kbd>a</kbd> followed by <kbd>x</kbd>.

Please refer to [this
website](https://translatedcode.wordpress.com/2017/07/24/installing-debian-on-qemus-64-bit-arm-virt-board/)
for more background information.

## Flash to SD-Card

By default, the recipe outputs a compressed image along with a `*.bmap` file.
Using the command `bmaptool` the image can be flashed efficiently to an sd-card.
This command is provided by the package `bmap-tools`, which is installed using 

```bash
sudo apt install bmap-tools 
```
Finally, the image can be flashed to the sd-card, using the following command:

```bash
sudo bmaptool copy debian-rpi4.img.gz <device>
```
where `<device>` is to be replaced with the device path the represents the sd-card, e.g. `/dev/sdc`.

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
