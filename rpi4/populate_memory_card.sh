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

    # Ask for sudo password using dialog
    password=$(dialog --backtitle "Device Formatting" --title "Authentication" --passwordbox "Enter your sudo password:" 10 50 3>&1 1>&2 2>&3)
    if [ $? -ne 0 ]; then
        dialog --backtitle "Device Formatting" --title "Cancelled" --msgbox "Authentication cancelled. No changes were made." 10 40
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
