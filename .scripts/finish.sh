#!/bin/bash

# --- Docker Service
docker ps

# --- Build Homer
docker stop homer
rm -rf /draco/.AppData/homer/*
mv /opt/draco-00/.scripts/homer/assets /draco/.AppData/homer/assets
docker start homer

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

mkdir -p /draco/storage/swap
chown -R shay /draco/storage/swap

echo "# --- Enter pihole user password --- #"
docker exec -it pihole pihole -a -p
echo "#  ---  COMPLETED | REBOOT SYSTEM  ---  #"
exit



