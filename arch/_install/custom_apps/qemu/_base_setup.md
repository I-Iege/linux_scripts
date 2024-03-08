# QEMU Setup for Arch Linux
>This tutorial is based on the ArchWiki of [KVM](https://wiki.archlinux.org/title/KVM) and [QEMU](https://wiki.archlinux.org/title/QEMU)

&nbsp;&nbsp;
##### Check if your Hardware supports Virtualization   
```sh
LC_ALL=C lscpu | grep Virtualization
```
###### *Note: The correct response is VT-x for Intel and AMD-V for AMD*

&nbsp;&nbsp;
##### Enable Virtualization in BIOS ( UEFI )
- Print your motherboard details
    ```sh
  cat /sys/devices/virtual/dmi/id/board_{vendor,name,version}
    ```   
- Based on the details, google how to enable Virtualization in BIOS ( UEFI ) and enable it

&nbsp;&nbsp;
##### Update your System
```
sudo pacman -Syyu
```

&nbsp;&nbsp;
##### Install Prerequisites
```
pacman -S qemu-full virt-manager virt-viewer dnsmasq 
pacman -S bridge-utils libguestfs ebtables vde2 openbsd-netcat
```

&nbsp;&nbsp;
##### Edit libvirt config file
```sh
sudo vi /etc/libvirt/libvirtd.conf
```

Uncomment these lines:
```sh
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

&nbsp;&nbsp;
##### Enable Virtualization Service
```sh
sudo systemctl enable --now libvirtd.service
```

&nbsp;&nbsp;
##### Add your user to the QEMU related groups and reboot the PC
```sh
sudo usermod -a -G libvirt-qemu "$USER"
sudo usermod -a -G libvirt "$USER"
reboot
```
###### *Note: This will alow you to open the Virtual Machine Manager without password prompt*

&nbsp;&nbsp;
##### Enable Virtual Network
```sh
sudo virsh net-start default 
```

&nbsp;&nbsp;
##### Confirm Virtual Network
```sh
sudo virsh net-list --all
```

&nbsp;&nbsp;
##### Open the Virtual Machine Manager
```sh
virt-manager
```
###### *Note: You can also start 'Virtual Machine Manager' from your Launcher aka 'Start Menu'*

&nbsp;&nbsp;
##### Virtual Machine Manager
<img src="https://github.com/sonus89/linux_scripts/assets/10185202/f6fe9cab-2f94-4391-b207-73de690b90eb" width="25%" height="25%" />

&nbsp;&nbsp;
##### Add Connection
<img src="https://github.com/sonus89/linux_scripts/assets/10185202/cdad7589-84ae-489a-b655-b95cb13578f9" width="25%" height="25%" />
<img src="https://github.com/sonus89/linux_scripts/assets/10185202/8ee330a4-eeba-43fb-812b-b2224df1dd12" width="25%" height="25%" />
<img src="https://github.com/sonus89/linux_scripts/assets/10185202/01b5fa58-3f9f-469b-afde-d690ac6414c0" width="25%" height="25%" />

&nbsp;Select: File → Add Connection&ensp;&ensp;&ensp;&ensp;Select: QEMU/KVM, click Connect

&nbsp;&nbsp;
##### Install and Setup different Operating Systems
&emsp;[Windows](https://github.com/sonus89/linux_scripts/blob/master/arch/_install/qemu/windows_setup.md)
&emsp;[MacOS](https://github.com/sonus89/linux_scripts/blob/master/arch/_install/qemu/macos.md)


