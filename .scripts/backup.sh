#!/bin/bash

# Backup AppData
tar -czf /srv/root/backups/AppData-$(date -I).tar.gz /srv/.AppData/*

# Deletion of files 4 days & older
find /srv/root/backups/ -type f -iname "*.tar.gz" -mtime +4 -delete
