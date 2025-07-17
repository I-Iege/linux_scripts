#!/bin/bash

####################################################################################################################
###														####
###	Arch Linux Deploy Script for Raspberry Pi 4 / 4B / 5							####
###	Author: Máté Gál											####
###	Contact: gal.mateo@protonmail.com									####
###														####
###	Usage Sample:												####
###	sudo sh arch_deploy.sh sdc										####
###														####
####################################################################################################################


check_packages() 
{
	# Check Prerequisites
	print_color "Checking prerequisites:" "green"
	package_list=("lsof" "gptfdisk" "util-linux" "parted" "libarchive")
	non_installed_packages=()
	all_installed=true

	# Iterating over the prerequisites ( list of packages )
	# And checking one-by-one if they are installed
	for package in "${package_list[@]}"; do
		if ! pacman -Q "$package" &> /dev/null; then
			non_installed_packages+=("$package")
			all_installed=false # A package is missing, so set the flag to false
		fi
	done

	# Evaluation / Installation
	if "$all_installed"; then
		print_color "All prerequisites satisfied. Nothing to do here." "blue"
	else
		print_color "⚠️ The following packages are NOT installed: ${non_installed_packages[*]}" "yellow"
		
		# Installing necessary packages
		for package in "${non_installed_packages[@]}"; do
			print_color "Installing $package..." "blue"
			sudo pacman -S --noconfirm "$package" > /dev/null
		done
		
	fi
}

####################################################################################################################

check_device_exist()
{
	print_color "\nPreparing device: $DEVICE" "green"
	# Check if the device exists
	if [[ ! -b "$DEVICE" ]]; then	
		print_color "Error: Device $DEVICE does not exist" "red"
		print_color "Available devices: " "yellow"
		ALL_DEVICES=$(lsblk -dno NAME)
		for device in $ALL_DEVICES; do
			print_color "$device" "yellow"
		done
		script_name=$0
		print_color "Usage Sample: sudo $script_name sda\n" "blue"
		exit 1 # Script will exit here if device is invalidS
	fi
}

swap_off()
{
	print_color "Turning Swap Off..." "blue"
	sudo swapoff ${DEVICE}* 2>/dev/null
}

kill_processes()
{
	print_color "Killing processes..." "blue"
	sudo lsof +f -- ${DEVICE}* 2>/dev/null | awk 'NR>1 {print $2}' | xargs -r sudo kill -9 >/dev/null 2>&1
}

unmount_partitions()
{
	print_color "Unmounting partitions..." "blue"
	partitions=$(lsblk -ln -o NAME $DEVICE | grep -v "^$(basename $DEVICE)$" | awk '{print "/dev/"$1}')
	for partition in $partitions; do
		sudo umount -l $partition > /dev/null 2>&1
	done
	
	# Check if they are actually unmounted
	mount_points=$(lsblk -n -o MOUNTPOINT $DEVICE | grep -v "^$")
	if [ "$mount_points" ]; then
		print_color "Could not unmount all partitions on: $DEVICE!" "red"
	fi
}

wipe_device()
{
	print_color "Wiping Partition Signatures..." "blue"
	print_color "Deleting Partition Table..." "blue"
	if command -v sgdisk &> /dev/null; then
		sudo sgdisk --zap-all ${DEVICE} > /dev/null 2>&1
	else
		sudo wipefs --all --force ${DEVICE} > /dev/null 2>&1
	fi	
	print_color "Force-Reload Partition Table..." "blue"
	sudo blockdev --rereadpt ${DEVICE}
}

partitioning()
{
	print_color "Create MS-DOS MBR..." "blue"
	sudo parted -s ${DEVICE} mklabel msdos > /dev/null 2>&1
	print_color "Partitioning..." "blue"
	sudo parted -s ${DEVICE} mkpart primary fat32 1MiB 513MiB > /dev/null 2>&1
	sudo parted -s ${DEVICE} mkpart primary ext4 513MiB 100% > /dev/null 2>&1
}

format_partitions()
{
	print_color "Formatting Partitions..." "blue"
	sudo mkfs.vfat -F32 ${DEVICE}1 > /dev/null 2>&1
	sudo mkfs.ext4 -F ${DEVICE}2 > /dev/null 2>&1
}

mount_partitions()
{
	print_color "Creating Mount Points..." "blue"
	root=/mnt/rpi_root
	boot=/mnt/rpi_boot
	for path in $boot $root; do
		sudo mkdir -p "$path"
	done

	print_color "Mounting Partitions..." "blue"
	sudo mount -t vfat ${DEVICE}1 $boot
	sudo mount ${DEVICE}2 $root
}

prep_device()
{
	check_device_exist $DEVICE
	swap_off $DEVICE
	kill_processes $DEVICE
	unmount_partitions $DEVICE
	wipe_device $DEVICE
	partitioning $DEVICE
	format_partitions $DEVICE
	mount_partitions $DEVICE
}

####################################################################################################################

download_image()
{
	print_color "\nDownloading Arch Linux Image:" "green"
}

####################################################################################################################

print_color()
{
	# Pretty print with colors in the Terminal
	local text="$1"
	local color_name="$2"
	local color_code=""

	# Define ANSI color codes
	case "$color_name" in
		"black")   color_code="\033[0;30m" ;;
		"red")     color_code="\033[0;31m" ;;
		"green")   color_code="\033[0;32m" ;;
		"yellow")  color_code="\033[0;33m" ;;
		"blue")    color_code="\033[0;34m" ;;
		*)         
		echo "Warning: Unsupported color '$color_name'. Using default (no color)." >&2
		color_code=""
		;;
	esac

	if [[ -n "$color_code" ]]; then
		echo -e "${color_code}${text}\033[0m"
	else
		echo "$text" # Print without color if code is empty (unsupported color)
	fi
}

####################################################################################################################

main()
{
	clear
	print_color "###########################################################################" "green"
	print_color "### Welcome to the Arch Linux Deploy Script for Raspberry Pi 4 and 4B!\t###" "green"
	print_color "### Usage Sample: sudo sh $0 sda\t\t\t\t###" "green"	
	print_color "### Author: Máté Gál\t\tContact: gal.mateo@protonmail.com\t###" "green"
	print_color "###########################################################################\n" "green"
	check_packages
	DEVICE=/dev/$1
	prep_device $DEVICE
	download_image
	
}

main $1
