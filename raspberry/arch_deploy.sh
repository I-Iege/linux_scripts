#!/bin/bash


check_packages() 
{
	# Check Prerequisites
	print_color "Checking prerequisites..." "blue"
	package_list=("lsof" "wget")
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
		print_color "All prerequisities satisfied. Nothing to do here." "green"
	else
		print_color "⚠️ The following packages are NOT installed: ${non_installed_packages[*]}" "yellow"
		
		# Installing necessary packages
		for package in "${non_installed_packages[@]}"; do
			print_color "Installing $package..." "green"
			sudo pacman -S --noconfirm "$package" > /dev/null
		done
	fi
}

set_device()
{
	DEVICE=/dev/$1

	# Check if the device exists
	if [[ ! -b "$DEVICE" ]]; then
		print_color "Selected Device: " "blue"
		print_color "Error: Device $DEVICE does not exist" "red"
		print_color "Available devices: " "yellow"
		DEVICES=$(lsblk -dno NAME)
		for device in $DEVICES; do
			print_color "/dev/$device" "yellow"
		done
		print_color "\nUsage Sample: sudo deploy_arch.sh sdc" "yellow"
		exit 1 # Script will exit here if device is invalid
	else
		print_color "Selected Device: " "blue"
		print_color "/dev/$1" "green"
	fi
	
}

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

main()
{
	clear
	check_packages
	set_device $1
}

main $1
