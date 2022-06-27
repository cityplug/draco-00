#!/bin/bash

# Backup AppData
tar -czf /draco/root/backups/AppData-$(date -I).tar.gz /draco/.AppData/*

# Deletion of files 4 days & older
find /draco/root/backups/ -type f -iname "*.tar.gz" -mtime +4 -delete
