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

    sudo mount -t vfat ${DEVICE}1 /mnt/boot
    sudo mount ${DEVICE}2 /mnt/root

    echo "Device $DEVICE is ready!"
}

populate_dev() {

    local url="http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz"
    local tarball="ArchLinuxARM-rpi-aarch64-latest.tar.gz"
    local root_mount="/mnt/root"
    local boot_mount="/mnt/boot"
    
    echo "Downloading root filesystem..."
    if [ ! -f "$(basename "$url")" ]; then
        wget "$url" || { echo "Download failed"; return 1; }
    else
        echo "File $(basename "$url") already exists, skipping download."
    fi
    
    echo "Extracting root filesystem..."
    sudo bsdtar -xpf "$tarball" -C "$root_mount" || { echo "Extraction failed"; return 1; }
    sudo mv $root_mount/boot/* $boot_mount
    
    echo "Syncing changes..."
    sync
    
    echo "Patching the Boot Config Files..."
    cd $boot_mount
    sudo sed -i 's/booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r};/booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr};/' boot.txt
    sudo sed -i 's/booti ${kernel_addr_r} - ${fdt_addr_r};/booti ${kernel_addr_r} - ${fdt_addr};/' boot.txt
    sudo ./mkscr
    
    echo "Unmounting drives..."
    sudo umount -l $root_mount
    sudo umount -l $boot_mount

    echo "Done."
}

prep_device $1
populate_dev
