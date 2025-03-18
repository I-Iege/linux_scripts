#!/bin/bash

prep_device() {
    DEVICE="/dev/$1"

    # Verify the device exists
    if [[ ! -b "$DEVICE" ]]; then
        echo "Error: Device $DEVICE does not exist."
        exit 1
    fi

    echo "Preparing device: $DEVICE..."

    # Kill processes using the device safely
    sudo lsof +f -- ${DEVICE}* | awk 'NR>1 {print $2}' | xargs -r sudo kill -9

    # Unmount all partitions of the device
    partitions=$(lsblk -ln -o NAME $DEVICE | grep -v "^$(basename $DEVICE)$" | awk '{print "/dev/"$1}')
    for partition in $partitions; do
        sudo umount -l $partition
        echo "$partition unmounted"
    done

    # Turn off Swap
    sudo swapoff ${DEVICE}* 2>/dev/null

    # Wipe signatures & partition table (fallback for missing sgdisk)
    if command -v sgdisk &> /dev/null; then
        sudo sgdisk --zap-all ${DEVICE}
    else
        sudo wipefs --all --force ${DEVICE}
    fi

    # Force partition table reload
    sudo blockdev --rereadpt ${DEVICE}

    # Partition the device using `parted`
    sudo parted -s ${DEVICE} mklabel msdos
    sudo parted -s ${DEVICE} mkpart primary fat32 1MiB 513MiB
    sudo parted -s ${DEVICE} mkpart primary ext4 513MiB 100%

    # Format partitions
    sudo mkfs.vfat -F32 ${DEVICE}1
    sudo mkfs.ext4 -F ${DEVICE}2

    # Create and mount directories
    for path in /mnt/boot /mnt/root; do
        sudo mkdir -p "$path"
    done

    sudo mount ${DEVICE}1 /mnt/boot
    sudo mount ${DEVICE}2 /mnt/root

    echo "Device $DEVICE is ready!"
}

prep_device $1
