populate_dev() {
    local url="http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz"
    local tarball="ArchLinuxARM-rpi-aarch64-latest.tar.gz"
    local root_mount="/mnt/root"
    local boot_mount="/mnt/boot"
    
    echo "Downloading root filesystem..."
    wget "$url" || { echo "Download failed"; return 1; }
    
    echo "Extracting root filesystem..."
    sudo bsdtar -xpf "$tarball" -C "$root_mount" || { echo "Extraction failed"; return 1; }
    
    echo "Syncing changes..."
    sync
    
    echo "Moving boot files..."
    sudo cp -r "$root_mount/boot"/* "$boot_mount" || { echo "Failed to move boot files"; return 1; }
    
    echo "Cleanup..."
    sudo rm "$tarball"
    
    echo "Done."
}

populate_dev
