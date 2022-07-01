#!/bin/bash

# --- Secure Fail2Ban
echo "#  ---  Securing fail2ban --- #"
cp /opt/draco-bm/.scripts/jail.local /etc/fail2ban/jail.local
systemctl restart fail2ban

# --- Addons
groupadd ssh-users
usermod -aG ssh-users shay
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config

# --- Setup samba share and config
echo "#  ---  Setting up samba share --- #"
systemctl stop smbd
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
cp /opt/draco-bm/.scripts/smb.conf /etc/samba/
echo "#  ---  Create samba user password --- #"
smbpasswd -a shay
echo
/etc/init.d/smbd restart
/etc/init.d/nmbd restart
usermod -aG sambashare shay
# --- Mount USB
echo "UUID=D8D3-CE07 /draco/storage/  auto   defaults,user,nofail  0   0" >> /etc/fstab

mount -a
chmod 777 -R /draco/storage/*
echo "#  ---  Samba share created --- #"

# ----> Next Script
./draco_net.sh