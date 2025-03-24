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

populate_dev
