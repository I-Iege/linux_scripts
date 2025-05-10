# How to Configure Nameservers for Arch Linux
 
&nbsp;&nbsp;
##### List Active Connections
```sh
sudo nmcli con show --active
```

&nbsp;&nbsp;
##### Copy the Connection Name
<img src="https://github.com/user-attachments/assets/3b2f7cb9-ad7e-48c9-b081-ef21d784150d" width="50%" height="50%" />

&nbsp;&nbsp;
##### Set DNS Server for the Connection
```sh
sudo nmcli con mod "SWAT Surveillance Van" ipv4.dns "195.186.1.111 9.9.9.9"
```

&nbsp;&nbsp;
##### Tell NetworkManager to not automatically obtain DNS servers for this connection
```sh
sudo nmcli con mod "SWAT Surveillance Van" ipv4.ignore-auto-dns yes
```

&nbsp;&nbsp;
##### Turn the Connection OFF and ON again
```sh
sudo nmcli con down "SWAT Surveillance Van"
sudo nmcli con up "SWAT Surveillance Van"
```

&nbsp;&nbsp;
##### Reboot your System
```sh
reboot
```

&nbsp;&nbsp;
##### Verify the DNS Servers
```sh
sudo systemctl enable --now systemd-resolved
sudo resolvectl status
```

