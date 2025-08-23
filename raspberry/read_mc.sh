#!/bin/bash

source_dev='/dev/sdc'
image_name='alarm.img'
loop_dev='/dev/loop0'

# Creating IMG File
sudo dd if=/dev/zero of=$image_name bs=512M count=8

# Creating Loop Device
sudo losetup -P $loop_dev $image_name

# Set Disk Label
sudo parted -s $loop_dev mklabel msdos

# Creating Partitions in Loop Device
sudo parted -s $loop_dev mkpart primary fat32 1MiB 513MiB
sudo parted -s $loop_dev mkpart primary ext4 513MiB 100%

# Formatting Partitions
sudo mkfs.vfat -F32 ${loop_dev}p1 > /dev/null 2>&1
sudo mkfs.ext4 -F ${loop_dev}p2 > /dev/null 2>&1

# Creating Mount Points
sudo mkdir -p '/mnt/loop/boot'
sudo mkdir -p '/mnt/loop/root'
sudo mkdir -p '/mnt/boot'
sudo mkdir -p '/mnt/root'

# Mounting Partitions
sudo mount ${loop_dev}p1 '/mnt/loop/boot'
sudo mount ${loop_dev}p2 '/mnt/loop/root'
sudo mount ${source_dev}1 '/mnt/root'
sudo mount ${source_dev}2 '/mnt/root'

# Copy Content
sudo rsync -avhP '/mnt/boot/.' '/mnt/loop/boot/'
sudo rsync -avhP '/mnt/root/.' '/mnt/loop/root/'

# Unmount everything
# sudo umount -l '/mnt/loop/boot'
# sudo umount -l '/mnt/loop/root'
# sudo umount -l '/mnt/root'
# sudo umount -l '/mnt/root'

# Detaching Loop Device
# sudo losetup -d $loop_dev

