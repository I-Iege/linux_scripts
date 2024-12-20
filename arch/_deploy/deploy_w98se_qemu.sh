#!/bin/bash

# A Simple Script for Arch-based Distros 
# to Deploy Windows98SE with KVM/QEMU


# Create Install Directories ###############################################
clear
echo -e "\033[32mDeploying Windows 98 SE Virtual Machine (QEMU) ...\033[0m"
vm_dir_name="virtual_machines"
os_dir_name="w98se"
if [ ! -d "$vm_dir_name" ]; then
	mkdir ~/$vm_dir_name
	if [ ! -d "$os_dir_name" ]; then
		mkdir ~/$vm_dir_name/$os_dir_name
		echo -e "\033[32mInstall Folder created in: "\
		"~/$vm_dir_name/$os_dir_name\033[0m"
	else
		echo -e "\033[33m~/$vm_dir_name/$os_dir_name"\ 
		"already exists."
	fi
fi
cd ~/$vm_dir_name/$os_dir_name
############################################################################


# Download Win98SE CD Image ################################################
cd_file_name="w98se.iso"
download_url="https://archive.org/download/windows-98-se-isofile/"\
"Windows%2098%20Second%20Edition.iso"
if [ ! -f "$cd_file_name" ]; then
    wget -nc --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
         --header="Referer: https://archive.org/" \
         --header="Accept: text/html,application/xhtml+xml,application/ \
         xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
         --header="Accept-Language: en-US,en;q=0.5" \
         -O "$cd_file_name" "$download_url"
else
    echo -e "\033[33mFile '$cd_file_name' already exists." \
		"Skipping Download.\033[0m"
fi
############################################################################


# Download (Modified) Win98SE Boot Floppy Image ############################
floppy_file_name="boot_floppy.ima"
download_url="https://github.com/JHRobotics/patcher9x/releases/download/"\
"v0.8.50/patcher9x-0.8.50-boot.ima"
if [ ! -f "$floppy_file_name" ]; then
    wget -nc --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
         --header="Referer: https://archive.org/" \
         --header="Accept: text/html,application/xhtml+xml,application/ \
         xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
         --header="Accept-Language: en-US,en;q=0.5" \
         -O "$floppy_file_name" "$download_url"
else
    echo -e "\033[33mFile '$floppy_file_name' already exists." \
		"Skipping Download.\033[0m"
fi
############################################################################


# Creating QEMU Image ######################################################
hard_disk_name="w98se.qcw"
if [ ! -f $hard_disk_name ]; then
	qemu-img create -f qcow2 $hard_disk_name 4096M
else
  echo -e "\033[33mFile '$hard_disk_name' already exists." \
		"Skipping Construction.\033[0m"
fi
############################################################################


# Configuring QEMU Image ###################################################
#qemu-system-i386 -nodefaults -rtc base=localtime -display sdl \
#-M pc,accel=kvm,hpet=off,usb=off -cpu host \
#-device VGA -device lsi -device ac97 -audio pa,id=audio0 \
#-netdev user,id=net0 -device pcnet,rombar=0,netdev=net0 \
#-drive if=floppy,format=raw,file=$floppy_file_name \
#-drive id=w98se,if=none,file=$hard_disk_name \
#-device scsi-hd,drive=w98se -monitor tcp::1234,server,nowait \
#-cdrom ~/$vm_dir_name/$install_dir_name/$cd_file_name -boot a &
############################################################################


# Methods to communicate with the Guest OS #################################
function send_char() {
    echo "sendkey $1" | socat - TCP:localhost:1234
}
function command() {
    for ((i=0; i<${#1}; i++)); do
        char="${1:i:1}"
        if [[ "$char" == " " ]]; then
            send_char "spc"
	elif [[ "$char" == "." ]]; then
            send_char "dot"
        elif [[ "$char" == "\n" ]]; then
            send_char "ret"
        else
            send_char "$char"
        fi
    done
}
############################################################################


# Creating Partition Table #################################################
#partitioning_commands=( "\n; disk\n; \n; \n; \n" 
#			"sleep 1; \n; esc; restart\n" 
#			)
#for cmd in "${commands[@]}"; do
#	sleep 1
#	eval "command '$cmd'"
#	echo "command '$cmd'"
#done
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
echo $xml_content > ~/$vm_dir_name/$install_dir_name/domain.xml
############################################################################
 
