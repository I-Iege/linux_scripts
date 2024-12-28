# Desktop Environment - Basic Installation Guide

## Install & Customize KDE

Install the Bare Minimum for KDE

    pacman -S plasma-desktop plasma-workspace plasma-framework5 plasma-nm plasma-pa konsole firefox sddm sddm-kcm 
  
Enable Display Manager & NetworkManager

    systemctl enable sddm
    systemctl enable NetworkManager
    exit
    reboot

Install Desktop Apps

    pacman -S dolphin packagekit-qt6 discover kscreen gwenview gedit kinfocenter spectacle ktorrent ark p7zip unrar

Install Partitioning Tools

    pacman -S gparted ntfs-3g dosfstools  
  
Setup Bluetooth

    pacman -S bluez bluez-utils bluedevil
    systemctl enable bluetooth

Customize Look and Feel

- Firefox -> Settings -> General -> Dark
- Customize KDE
    - Global Theme -> Get New -> Download a Theme ( i.e. Utterly Sweet )
    - Night Light
    - Desktop Effects
        - Magic Lamp
        - Blur
- Plasma Style -> Utterly Round
- Splash Screen -> Get New -> Arch
- Login Screen -> Get New -> Utterly Sweet
- Screen Locking -> Never
- Power Management -> Do Nothing
- Konsole -> Settings -> Configure Konsole -> Profiles -> New -> OK -> Select new Profile -> Set as Default -> Edit -> Appearance -> Get New -> Select Color Scheme ( i.e. Utterly Sweet ) -> Install & Apply 

Add Hotkey for Screenshot

    1. Open Spectacle
    2. Select: Configure -> Shortcuts
    3. Add Win+Shift+S as Capture Rectangular Region

Install yay Package Manager

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

