# How to Configure Nameservers for Arch Linux
 
&nbsp;&nbsp;
##### List available Connections
```sh
sudo nmcli con show
```

&nbsp;&nbsp;
##### Copy the Connection Name
<img src="https://github.com/user-attachments/assets/93b5b28d-1e21-49f2-a3ea-8c4e94c24901" width="50%" height="50%" />

&nbsp;&nbsp;
##### Set DNS Server for the Connection
```sh
sudo nmcli con mod "SWAT Surveillance Van" ipv4.dns "195.186.1.111 1.1.1.1"
```


