#!/bin/bash

# Raspbian (draco.machine v2.1) setup script.

# --- Remove Bloatware
echo "#  ---  Removing Bloatware  ---  #"
apt update && apt dist-upgrade -y
apt-get autoremove && apt-get autoclean -y
rm -rf python_games && rm -rf /usr/games/
apt-get purge --auto-remove libraspberrypi-dev libraspberrypi-doc -y

# --- Disable Services
echo "#  ---  Disabling Bloatware Services  ---  #"
systemctl stop alsa-state.service hciuart.service sys-kernel-debug.mount \
systemd-udev-trigger.service rpi-eeprom-update.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

systemctl disable alsa-state.service hciuart.service sys-kernel-debug.mount \
systemd-udev-trigger.service rpi-eeprom-update.service systemd-journald.service \
systemd-fsck-root.service systemd-logind.service wpa_supplicant.service \
bluetooth.service apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service

# --- Over clcok raspberry pi & increase GPU
sed -i '40i\over_voltage=6\narm_freq_min=1000\narm_freq=2000\n' /boot/config.txt

# --- Disable Bluetooth & Wifi
echo "
disable_splash=1
dtoverlay=disable-wifi
dtoverlay=disable-bt" >> /boot/config.txt

# --- Change root password
echo "#  ---  Change root password  ---  #"
passwd root
echo "#  ---  Root password changed  ---  #"

# --- Initialzing draco
hostnamectl set-hostname Draco-BM.home.lan
hostnamectl set-hostname "Draco-BM" --pretty
rm -rf /etc/hosts
cp /opt/draco-bm/.scripts/hosts /etc/hosts

# --- Install Packages
echo "#  ---  Installing New Packages  ---  #"
apt install unattended-upgrades -y
apt install fail2ban -y
apt install netdiscover -y
apt install samba samba-common-bin -y
# --- Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update && apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# --- Install Docker-Compose
curl -L "https://github.com/docker/compose/releases/download/$(curl https://github.com/docker/compose/releases | grep -m1 '<a href="/docker/compose/releases/download/' | grep -o 'v[0-9:].[0-9].[0-9]')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

systemctl enable docker
apt install docker-compose -y
usermod -aG docker shay && docker-compose --version

# --- Addons
echo "#  ---  Running Addons  ---  #"
mkdir -p /draco
mkdir -p /draco/.AppData/
mkdir -p /draco/storage/

rm -rf /etc/update-motd.d/* && rm -rf /etc/motd
rm -rf /etc/issue.d/cockpit.issue /etc/motd.d/cockpit
cp /opt/draco-bm/10-uname /etc/update-motd.d/ && chmod +x /etc/update-motd.d/10-uname

cp /opt/draco-bm/.scripts/ssh_config /home/shay/.ssh/config

# --- Backup Script
(crontab -l 2>/dev/null; echo "0 1 * * * /opt/draco-bm/.scripts/backup.sh") | crontab -

# --- Create and allocate swap
echo "#  ---  Creating 4GB swap file  ---  #"
fallocate -l 4G /swapfile
# --- Sets permissions on swap
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
# --- Add swap to the /fstab file
sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'
# --- Verify command
cat /etc/fstab
# --- Clear older versions
sh -c 'echo "apt autoremove -y" >> /etc/cron.monthly/autoremove'
# --- Make file executable
chmod +x /etc/cron.monthly/autoremove
echo "#  ---  4GB swap file created | SYSTEM REBOOTING  ---  #"

reboot

# ----> Next Script | security-samba.sh