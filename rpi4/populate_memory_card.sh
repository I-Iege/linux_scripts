#!/bin/bash

# Function to format the selected device
format_device() {
    local device=$1

    # Check if the device exists
    if [ ! -e "/dev/$device" ]; then
        dialog --backtitle "Device Formatting" --title "Error" --msgbox "Error: Device /dev/$device does not exist." 10 40
        return 1
    fi

    # Confirmation dialog
    dialog --backtitle "Device Formatting" --title "Confirmation" --yesno "Are you sure you want to format /dev/$device? All data will be lost!" 10 50
    if [ $? -ne 0 ]; then
        dialog --backtitle "Device Formatting" --title "Cancelled" --msgbox "Formatting cancelled. No changes were made." 10 40
        return 1
    fi

    # Clear the terminal before starting the progress bar
    clear

    # Start formatting process
    (
        echo "10" ; sleep 1
        echo "Removing filesystems, signatures, and partition tables..."
        echo "$password" | sudo -S wipefs --all "/dev/$device"

        echo "30" ; sleep 1
        echo "Zeroing out the first 10MB of the device..."
        # Suppress dd output and redirect it to /dev/null
        echo "$password" | sudo -S dd if=/dev/zero of="/dev/$device" bs=1M count=10 status=progress oflag=direct 2>/dev/null

        echo "70" ; sleep 1
        echo "Finalizing..."
        sleep 1

        echo "100" ; sleep 1
    ) | dialog --backtitle "Device Formatting" --title "Formatting /dev/$device" --gauge "Please wait while the device is being formatted..." 10 50 0

    # Completion message
    dialog --backtitle "Device Formatting" --title "Success" --msgbox "Device /dev/$device has been formatted and all data erased." 10 50
    
    partition_device "$1"
}


partition_device() {

# Check if a device is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 /dev/sdX"
    echo "Please specify the device (e.g., /dev/sdb)."
    exit 1
fi

DEVICE=/dev/$1

# Confirm the device with the user
echo "You are about to partition and format $DEVICE."
echo "THIS WILL ERASE ALL DATA ON THE DEVICE!"
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Operation canceled."
    exit 0
fi

# Step 1: Partition the SD card using fdisk
echo "Partitioning /dev/$DEVICE..."
sudo fdisk $DEVICE <<EOF
o
n
p
1

+200M
t
c
n
p
2


w

EOF

# Check if partitioning was successful
if [ $? -ne 0 ]; then
    echo "Partitioning failed. Exiting."
    exit 1
fi

# Step 2: Create and mount the FAT filesystem
echo "Creating FAT filesystem on ${DEVICE}1..."
sudo mkfs.vfat ${DEVICE}1
if [ $? -ne 0 ]; then
    echo "Failed to create FAT filesystem. Exiting."
    exit 1
fi

mkdir -p boot
mount ${DEVICE}1 boot
if [ $? -ne 0 ]; then
    echo "Failed to mount ${DEVICE}1. Exiting."
    exit 1
fi

# Step 3: Create and mount the ext4 filesystem
echo "Creating ext4 filesystem on ${DEVICE}2..."
sudo mkfs.ext4 ${DEVICE}2
if [ $? -ne 0 ]; then
    echo "Failed to create ext4 filesystem. Exiting."
    exit 1
fi

mkdir -p root
mount ${DEVICE}2 root
if [ $? -ne 0 ]; then
    echo "Failed to mount ${DEVICE}2. Exiting."
    exit 1
fi

echo "Partitioning and formatting completed successfully."
echo "FAT filesystem mounted at ./boot"
echo "ext4 filesystem mounted at ./root"
}

# List block devices
devices=$(lsblk -d -o NAME,SIZE | tail -n +2 | awk '{print $1, $2}')

# Check if any devices are found
if [ -z "$devices" ]; then
    echo "No block devices found."
    exit 1
fi

# Prepare dialog menu options
menu_options=()
while read -r name size; do
    menu_options+=("$name" "$size")
done <<< "$devices"

# Display dialog menu to select a device
selected_device=$(dialog --title "Select Device" \
                         --menu "Please select the device:" 15 60 10 \
                         "${menu_options[@]}" \
                         3>&1 1>&2 2>&3)

# Check if a device was selected
if [ -n "$selected_device" ]; then
    # Call the function to format the device
    format_device "$selected_device"
else
    echo "No device was selected."
    exit 0
fi
