#!/bin/bash

# A Simple Script for Arch-based Distros 
# to Deploy Windows98SE with KVM/QEMU

# Constants ################################################################
os_name="w98se"
vm_dir_name="$HOME/virtual_machines"
os_dir_name="$vm_dir_name/$os_name"
cd_file_name="$os_name.iso"
floppy_file_name="boot_floppy.ima"
hard_disk_name="$os_name.qcow2"
cd_iso_url="https://archive.org/download/windows-98-se-isofile/"\
"Windows%2098%20Second%20Edition.iso"
floppy_url="https://github.com/JHRobotics/patcher9x/releases/"\
"download/v0.8.50/patcher9x-0.8.50-boot.ima"
############################################################################


# Create Install Directories ############################################### 
clear
echo -e "\033[32mDeploying Windows 98 SE Virtual Machine (QEMU) ...\033[0m"
if [ ! -d "$os_dir_name" ]; then
    mkdir -p "$os_dir_name"
    echo -e "\033[32mDeploy folder created in: $os_dir_name\033[0m"
else
    echo -e "\033[33mFolder $os_dir_name already exists. "\
"Skipping creation.\033[0m"
fi
cd "$os_dir_name" || { echo "Failed to navigate to $os_dir_name"; exit 1; }
############################################################################


# Download Win98SE CD Image ################################################
if [ ! -f "$cd_file_name" ]; then
    wget -nc -O "$cd_file_name" "$iso_download_url" && \
    echo -e "\033[32mDownloaded $cd_file_name\033[0m" || \
    echo -e "\033[31mFailed to download $cd_file_name\033[0m"
else
    echo -e "\033[33mFile '$cd_file_name' already exists. "\
"Skipping download.\033[0m"
fi
############################################################################


# Download Modified Win98SE Boot Floppy Image ##############################
if [ ! -f "$floppy_file_name" ]; then
    wget -nc -O "$floppy_file_name" "$floppy_download_url" && \
    echo -e "\033[32mDownloaded $floppy_file_name\033[0m" || \
    echo -e "\033[31mFailed to download $floppy_file_name\033[0m"
else
    echo -e "\033[33mFile '$floppy_file_name' already exists. "\
"Skipping download.\033[0m"
fi
############################################################################


# Create QEMU Image ########################################################
if [ ! -f "$hard_disk_name" ]; then
    qemu-img create -f qcow2 "$hard_disk_name" 4G && \
    echo -e "\033[32mCreated QEMU image $hard_disk_name\033[0m" || \
    echo -e "\033[31mFailed to create QEMU image $hard_disk_name\033[0m"
else
    echo -e "\033[33mFile '$hard_disk_name' already exists."\
"Skipping creation.\033[0m"
fi
############################################################################


# Launch QEMU with Windows 98 SE ###########################################
qemu-system-i386 -nodefaults -rtc base=localtime -display sdl \
-M pc,accel=kvm,hpet=off,usb=off -cpu host -device VGA -device lsi \
-audiodev alsa,id=audio0,out.frequency=44100,out.channels=2 \
-netdev user,id=net0 -device pcnet,rombar=0,netdev=net0 \
-drive if=floppy,format=raw,file="$floppy_file_name" \
-drive id=w98se,if=none,file="$hard_disk_name" \
-device scsi-hd,drive=w98se -monitor tcp::1234,server,nowait \
-cdrom "$os_dir_name/$cd_file_name" -boot a &
############################################################################


# Methods to communicate with the Guest OS #################################
function send_char() {
    echo "sendkey '$1'" | socat - TCP:localhost:1234
}
function send_string() {
  local string="$1"

  for char in $(echo "$string" | fold -w 1); do
    if [[ "$char" == "\n" ]]; then
      send_char "ret"
    else
      send_char "$char"
    fi
  done
}
############################################################################


# Creating Partition Table #################################################
send_string "\n"
############################################################################


#############
#qemu-system-i386 -nodefaults -rtc base=localtime -display sdl \
#-M pc,accel=kvm,hpet=off,usb=off -cpu host \
#-device VGA -device lsi -device ac97 -audio pa,id=audio0 \
#-netdev user,id=net0 -device pcnet,rombar=0,netdev=net0 \
#-drive if=floppy,format=raw,file=boot_floppy.ima \
#-drive id=w98se,if=none,file=w98se.qcw \
#-device scsi-hd,drive=w98se -monitor tcp::1234,server,nowait \
#-drive id=scd04,if=none,media=cdrom,file=Security9_enu_15.iso -device scsi-cd,drive=scd04
#############

# STEPS

# fdisk & enter
# 3 x enter
# sleep 2 ( creating DOS partition )
# enter
# esc
# restart & enter

# format c: /s & enter
# y & enter
# win98se & enter
# type config.sys & enter
# shcdx33f /d:MSCD001 & enter
# xcopy32 /s /e d:\win98 c:\mycd & enter

# patch9x c:\mycd & enter



# enter 
#    -device VGA -device Isi -device ac97 \
#    -netdev user,id=net0 -device pcnet,rombar=0,netdev=net0 \
#    -drive if=floppy,format=raw,file= \
#    -drive id=win98,if=none,file=win98se.qcw -device scsi-hd,drive=win98se \
#    -drive id=scd04,if=none,media=cdrom, file=Security9_enu_15.iso -device scsi-cd,drive=scd04
    
	

	
w98se_product_key="B8MFR-CFTGQ-C9PBW-VHG3J-3R3YW"


# Create Domain XML ########################################################
xml_content="<domain type='kvm'>
  <name>w98se</name>
  <memory unit='KiB'>1024000</memory> <vcpu>1</vcpu>
  <os>
    <type arch='i686' machine='pc-i440fx-2.11'>hvm</type>
    <boot dev='cdrom'/>
  </os>
  <devices>
    <disk type='file' device='cdrom'>
      <source file='~/w98se/w98se.iso'/>
      <target dev='hdc' bus='ide'/>
      <readonly/>
    </disk>
    <disk type='file' device='disk'>
      <source file='~/w98se/w98se.qcw'/>
      <target dev='hda' bus='ide'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='pcnet'/>
    </interface>
  </devices>
</domain>"
############################################################################
 
